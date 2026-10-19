#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
HOST="${HOSTINGER_FTP_HOST:-}"
USER="${HOSTINGER_FTP_USER:-}"
PASS="${HOSTINGER_FTP_PASS:-}"
REMOTE="${HOSTINGER_FTP_REMOTE_DIR:-public_html/devpath}"

if [[ -z "$HOST" || -z "$USER" || -z "$PASS" ]]; then
  echo "Set HOSTINGER_FTP_HOST, HOSTINGER_FTP_USER, and HOSTINGER_FTP_PASS to deploy." >&2
  exit 1
fi

if ! command -v lftp >/dev/null 2>&1; then
  echo "lftp is required for SFTP deploy." >&2
  exit 1
fi

lftp -u "$USER","$PASS" "$HOST" <<EOF
set ssl:verify-certificate yes
mkdir -p $REMOTE
mkdir -p $REMOTE/privacy-policy
mkdir -p $REMOTE/assets/css
mkdir -p $REMOTE/assets/img
cd $REMOTE
lcd $ROOT
put index.html
cd privacy-policy
lcd $ROOT/privacy-policy
put index.html
cd ../assets/css
lcd $ROOT/assets/css
put site.css
cd ../img
lcd $ROOT/assets/img
put devpath-icon.png
bye
EOF

echo "Upload complete to $REMOTE"
