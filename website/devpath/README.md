# DevPath static site (solverpros.com)

Upload the contents of this folder to your Hostinger **public_html/devpath/** directory so that:

- Landing page: `https://solverpros.com/devpath/`
- Privacy Policy: `https://solverpros.com/devpath/privacy-policy/`

## Hostinger (hPanel) upload

1. Sign in to Hostinger hPanel → **Files** → **File Manager**.
2. Open `public_html` (do not replace unrelated site files).
3. Create folder `devpath` if it does not exist.
4. Upload everything under `website/devpath/` preserving structure:
   - `index.html`
   - `privacy-policy/index.html`
   - `assets/css/site.css`
   - `assets/img/devpath-icon.png`
5. Ensure folder URLs work (trailing slash or `index.html`).

## Optional SFTP (if credentials are configured locally)

```bash
# Example — set these in your environment; never commit secrets.
export HOSTINGER_FTP_HOST=ftp.solverpros.com
export HOSTINGER_FTP_USER=your_user
export HOSTINGER_FTP_PASS=your_password
./website/devpath/deploy-sftp.sh
```

## Verify after upload

```bash
curl -I https://solverpros.com/devpath/
curl -I https://solverpros.com/devpath/privacy-policy/
```

Both should return `HTTP/2 200` (or `301` to HTTPS) and serve HTML.
