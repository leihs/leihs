# leihs-docker: HTTP-VHost (Port 80)
# Konvertiert aus leihs_deploy roles/reverse-proxy-leihs/templates/http.conf.
# __LEIHS_EXTERNAL_HOSTNAME__ wird beim Containerstart von render-config.sh ersetzt.

<VirtualHost *:80>

  ServerName __LEIHS_EXTERNAL_HOSTNAME__

  RewriteEngine on

  Include /etc/apache2/leihs/conf.d/*.conf

  ###############################################################################
  ### logging ###################################################################
  ###############################################################################

  #ErrorLog ${APACHE_LOG_DIR}/leihs_default_error.log
  #LogLevel error

  #CustomLog ${APACHE_LOG_DIR}/leihs_default_access.log combined


</VirtualHost>
# vim: syntax=apache
