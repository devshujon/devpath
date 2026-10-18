/// Keep in sync with [pubspec.yaml] `version:` (used when [PackageInfo] unavailable).
const String kAppVersionLabel = '1.3.0';
const String kAppBuildNumber = '15'; // matches pubspec +N

String get kAppFullVersionLabel => '$kAppVersionLabel+$kAppBuildNumber';
