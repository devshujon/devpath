# DevPath static site (devshujon.com)

Upload the contents of this folder to the web root that serves **https://devshujon.com/** so that:

- Landing page: `https://devshujon.com/devpath/`
- Privacy Policy: `https://devshujon.com/devpath/privacy-policy/`
- Developer profile (linked from pages): `https://profiles.wordpress.org/devshujon/`

This site is **independent** of any other domain or hosting account (for example SolverPros). Use the credentials and document root for **devshujon.com** only.

## Typical deployment paths

Your host may use one of these layouts—confirm in your hosting panel before uploading:

| Host setup | Upload target (example) |
|------------|-------------------------|
| cPanel / Apache `public_html` | `public_html/devpath/` |
| WordPress in site root | Often `public_html/devpath/` as static HTML **outside** WP routing, or a subdirectory mapped by your host |
| SFTP user jailed to domain root | `devpath/` under that root |

Preserve existing site files; upload **only** the `devpath` folder and its contents.

## WordPress Elementor (HTML widgets)

If DevPath pages are built in Elementor instead of static upload, paste these **self-contained** snippets (one widget per page):

| Page | File |
|------|------|
| Landing | `elementor-landing-widget.html` |
| Privacy Policy | `elementor-privacy-widget.html` |

Use full-width sections and a single HTML widget per page. Snippets include scoped `devpath-` IDs/classes, inline styles, and no external CSS/JS.

## Files to upload (static HTML)

```
devpath/
  index.html
  privacy-policy/index.html
  assets/css/site.css
  assets/img/devpath-icon.png
  elementor-landing-widget.html      (reference only — paste into WP)
  elementor-privacy-widget.html      (reference only — paste into WP)
```

## Manual upload (FTP / SFTP / File Manager)

1. Sign in to the hosting control panel or SFTP account for **devshujon.com**.
2. Open the document root for that domain (not another domain on the same panel unless it shares the same root).
3. Create **`devpath`** if needed.
4. Upload all files preserving paths.
5. Confirm URLs load over **HTTPS** without login or geo blocks.

## Optional SFTP script

```bash
# Set credentials for devshujon.com only — never commit secrets.
export DEVPATH_FTP_HOST=ftp.example.devshujon.com   # your host’s FTP/SFTP hostname
export DEVPATH_FTP_USER=your_user
export DEVPATH_FTP_PASS=your_password
export DEVPATH_FTP_REMOTE_DIR=public_html/devpath    # adjust to your document root
./website/devpath/deploy-sftp.sh
```

## Verify after deploy (required before Play Console)

```bash
curl -I https://devshujon.com/devpath/
curl -I https://devshujon.com/devpath/privacy-policy/
```

Expect **200** (or redirect to HTTPS then **200**) and HTML responses. Do not use these URLs on Google Play until verification succeeds.
