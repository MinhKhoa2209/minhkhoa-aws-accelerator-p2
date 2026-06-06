#!/bin/bash
set -euxo pipefail

dnf update -y
dnf install -y nginx

echo "${app_html_base64}" | base64 --decode >/usr/share/nginx/html/index.html
echo "${app_css_base64}" | base64 --decode >/usr/share/nginx/html/styles.css
echo "${app_js_base64}" | base64 --decode >/usr/share/nginx/html/app.js

systemctl enable nginx
systemctl restart nginx
