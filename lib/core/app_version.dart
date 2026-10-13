/// Keep in sync with [pubspec.yaml] `version:` (used when [PackageInfo] unavailable).
const String kAppVersionLabel = '1.2.1';
const String kAppBuildNumber = '9'; // matches pubspec +N

String get kAppFullVersionLabel => '$kAppVersionLabel+$kAppBuildNumber';
