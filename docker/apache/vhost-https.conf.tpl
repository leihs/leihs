# leihs-docker: HTTPS-VHost (Port 443)
# Konvertiert aus leihs_deploy roles/reverse-proxy-leihs/templates/https.conf.
# Verwendet das Snakeoil-Zertifikat — für den Produktivbetrieb eigene
# Zertifikate als Volume unter /etc/ssl/certs|private bereitstellen
# (LEIHS_SSL_CERT_FILE / LEIHS_SSL_KEY_FILE).

<VirtualHost *:443>

  ServerName __LEIHS_EXTERNAL_HOSTNAME__

  SSLEngine on
  SSLCertificateFile /etc/ssl/certs/ssl-cert-snakeoil.pem
  SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key

  SSLProxyEngine on
  SSLProxyVerify none
  SSLProxyCheckPeerCN off
  SSLProxyCheckPeerName off

  Header always set X-Content-Type-Options nosniff

  Include /etc/apache2/leihs/conf.d/*.conf

</VirtualHost>

# --- START SHARED SSL CONFIG ---
# Mozilla Guideline v5.6, Apache 2.4, intermediate configuration
Header always set Strict-Transport-Security "max-age=63072000"

# intermediate configuration
SSLProtocol             all -SSLv3 -TLSv1 -TLSv1.1
SSLCipherSuite          ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
SSLHonorCipherOrder     off
SSLSessionTickets       off
# --- END SHARED SSL CONFIG ---

# vim: syntax=apache
