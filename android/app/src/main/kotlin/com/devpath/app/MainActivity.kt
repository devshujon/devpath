package com.devpath.app

import android.content.ActivityNotFoundException
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.OpenableColumns
import android.provider.Settings
import android.util.Base64
import android.view.View
import android.view.ViewGroup
import android.webkit.WebView
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.IOException
import java.nio.charset.Charset

class MainActivity : FlutterActivity() {
    private val batteryChannel = "com.devpath.app/battery"
    private val platformViewsChannel = "com.devpath.app/platformviews"
    private val openFileChannelName = "com.devpath.app/open_file"

    private var openFileChannel: MethodChannel? = null
    private var pendingOpen: Map<String, Any?>? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, platformViewsChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hideStaleWebViews" -> runOnUiThread {
                        val hidden = hideStaleWebViews(window.decorView)
                        result.success(hidden)
                    }
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, batteryChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isIgnoringBatteryOptimizations" ->
                        result.success(isIgnoringBatteryOptimizations())
                    "requestIgnoreBatteryOptimizations" ->
                        result.success(requestIgnoreBatteryOptimizations())
                    "openOemAutostartSettings" ->
                        result.success(openOemAutostartSettings())
                    else -> result.notImplemented()
                }
            }

        openFileChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            openFileChannelName,
        ).also { channel ->
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "consumePendingOpen" -> {
                        val payload = pendingOpen
                        pendingOpen = null
                        result.success(payload)
                    }
                    "readOpenUri" -> {
                        val uriStr = call.argument<String>("uri")
                        val maxBytes = call.argument<Int>("maxBytes") ?: (1024 * 1024)
                        if (uriStr.isNullOrBlank()) {
                            result.success(mapOf("error" to "invalid_uri"))
                            return@setMethodCallHandler
                        }
                        result.success(readContentUri(Uri.parse(uriStr), maxBytes))
                    }
                    else -> result.notImplemented()
                }
            }
        }

        captureIntent(intent)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        captureIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        captureIntent(intent)
        val payload = pendingOpen
        if (payload != null) {
            openFileChannel?.invokeMethod("onNewOpenIntent", payload)
        }
    }

    private fun captureIntent(intent: Intent?) {
        if (intent == null) return
        val payload = extractOpenPayload(intent) ?: return
        pendingOpen = payload
    }

    private fun extractOpenPayload(intent: Intent): Map<String, Any?>? {
        return when (intent.action) {
            Intent.ACTION_VIEW -> {
                val uri = intent.data ?: return null
                metaForUri(uri).toMutableMap().apply {
                    put("uri", uri.toString())
                    put("action", "view")
                    put("mimeType", intent.type ?: contentResolver.getType(uri) ?: "")
                }
            }
            Intent.ACTION_SEND -> {
                val uri: Uri? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    intent.getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
                } else {
                    @Suppress("DEPRECATION")
                    intent.getParcelableExtra(Intent.EXTRA_STREAM)
                }
                val text = intent.getStringExtra(Intent.EXTRA_TEXT)
                if (uri != null) {
                    metaForUri(uri).toMutableMap().apply {
                        put("uri", uri.toString())
                        put("action", "send")
                        put("mimeType", intent.type ?: contentResolver.getType(uri) ?: "")
                    }
                } else if (!text.isNullOrBlank()) {
                    mapOf(
                        "uri" to "",
                        "action" to "send",
                        "mimeType" to (intent.type ?: "text/plain"),
                        "inlineText" to text,
                        "displayName" to "shared.txt",
                    )
                } else {
                    null
                }
            }
            else -> null
        }
    }

    private fun metaForUri(uri: Uri): Map<String, Any?> {
        var displayName: String? = null
        var sizeBytes: Long? = null
        try {
            contentResolver.query(uri, null, null, null, null)?.use { cursor ->
                if (cursor.moveToFirst()) {
                    val nameIndex = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                    if (nameIndex >= 0) displayName = cursor.getString(nameIndex)
                    val sizeIndex = cursor.getColumnIndex(OpenableColumns.SIZE)
                    if (sizeIndex >= 0 && !cursor.isNull(sizeIndex)) {
                        sizeBytes = cursor.getLong(sizeIndex)
                    }
                }
            }
        } catch (_: Exception) {
            // Best-effort metadata only.
        }
        return mapOf(
            "displayName" to displayName,
            "sizeBytes" to sizeBytes,
        )
    }

    private fun readContentUri(uri: Uri, maxBytes: Int): Map<String, Any?> {
        return try {
            contentResolver.openInputStream(uri)?.use { stream ->
                val buffer = ByteArray(maxBytes + 1)
                var total = 0
                while (total <= maxBytes) {
                    val read = stream.read(
                        buffer,
                        total,
                        minOf(8192, maxBytes + 1 - total),
                    )
                    if (read <= 0) break
                    total += read
                }
                when {
                    total == 0 -> mapOf("error" to "empty")
                    total > maxBytes -> mapOf("error" to "too_large")
                    else -> {
                        val bytes = buffer.copyOf(total)
                        val asUtf8 = String(bytes, Charset.forName("UTF-8"))
                        if (asUtf8.contains('\uFFFD')) {
                            mapOf(
                                "encoding" to "base64",
                                "bytes" to Base64.encodeToString(bytes, Base64.NO_WRAP),
                            )
                        } else {
                            mapOf("encoding" to "utf8", "text" to asUtf8)
                        }
                    }
                }
            } ?: mapOf("error" to "not_found")
        } catch (e: SecurityException) {
            mapOf("error" to "permission_denied")
        } catch (_: IOException) {
            mapOf("error" to "not_found")
        } catch (_: Exception) {
            mapOf("error" to "read_failed")
        }
    }

    private fun isIgnoringBatteryOptimizations(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return true
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        return pm.isIgnoringBatteryOptimizations(packageName)
    }

    @Suppress("BatteryLife")
    private fun requestIgnoreBatteryOptimizations(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return true
        return try {
            val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                data = Uri.parse("package:$packageName")
            }
            startActivity(intent)
            true
        } catch (e: ActivityNotFoundException) {
            try {
                startActivity(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
                true
            } catch (_: Exception) {
                false
            }
        }
    }

    /** Hide orphan WebViews; do not destroy (Honor black-screen after destroy). */
    private fun hideStaleWebViews(root: View): Int {
        var count = 0
        if (root is WebView) {
            try {
                root.stopLoading()
                root.loadUrl("about:blank")
                root.visibility = View.GONE
                count++
            } catch (_: Exception) {
                // Best-effort only.
            }
            return count
        }
        if (root is ViewGroup) {
            for (i in root.childCount - 1 downTo 0) {
                count += hideStaleWebViews(root.getChildAt(i))
            }
        }
        return count
    }

    private fun openOemAutostartSettings(): Boolean {
        val manufacturer = Build.MANUFACTURER.lowercase()

        val components = when {
            manufacturer.contains("xiaomi") || manufacturer.contains("redmi") -> listOf(
                ComponentName(
                    "com.miui.securitycenter",
                    "com.miui.permcenter.autostart.AutoStartManagementActivity"
                )
            )
            manufacturer.contains("oppo") || manufacturer.contains("realme") -> listOf(
                ComponentName(
                    "com.coloros.safecenter",
                    "com.coloros.safecenter.permission.startup.StartupAppListActivity"
                ),
                ComponentName(
                    "com.oppo.safe",
                    "com.oppo.safe.permission.startup.StartupAppListActivity"
                )
            )
            manufacturer.contains("vivo") || manufacturer.contains("iqoo") -> listOf(
                ComponentName(
                    "com.vivo.permissionmanager",
                    "com.vivo.permissionmanager.activity.BgStartUpManagerActivity"
                )
            )
            manufacturer.contains("samsung") -> listOf(
                ComponentName(
                    "com.samsung.android.lool",
                    "com.samsung.android.sm.ui.battery.BatteryActivity"
                )
            )
            manufacturer.contains("huawei") || manufacturer.contains("honor") -> listOf(
                ComponentName(
                    "com.huawei.systemmanager",
                    "com.huawei.systemmanager.optimize.process.ProtectActivity"
                )
            )
            else -> emptyList()
        }

        for (cn in components) {
            try {
                val intent = Intent().apply {
                    component = cn
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                startActivity(intent)
                return true
            } catch (_: Exception) {
                // try next
            }
        }

        return try {
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:$packageName")
            }
            startActivity(intent)
            true
        } catch (_: Exception) {
            false
        }
    }
}
