# leihs-docker: Basic-Auth-Fragment
# Konvertiert aus leihs_deploy roles/reverse-proxy-leihs/templates/basic_auth.conf.
# Wird von render-config.sh aktiviert, wenn RESTRICT_ACCESS_VIA_BASIC_AUTH=true.

<LocationMatch "^(?!/webstats.*|/admin.*)">
    AuthType Basic
    AuthName "Access to Leihs on __LEIHS_EXTERNAL_HOSTNAME__ is restricted"
    AuthBasicProvider file
    AuthUserFile "/etc/leihs/leihs.htpasswd"
    Require valid-user
</LocationMatch>

# vim: syntax=apache
