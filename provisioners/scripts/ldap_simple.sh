mysql -uroot -p -e "INSTALL PLUGIN authentication_ldap_simple SONAME 'authentication_ldap_simple.so';"

echo "Set these in my.cnf: "
echo "authentication_ldap_simple_server_host='slapd'"
echo "authentication_ldap_simple_bind_base_dn='dc=support,dc=local'"
echo "...and then restart mysqld"

echo "Try: mysql -uroot -p -e \"SELECT PLUGIN_NAME, PLUGIN_STATUS FROM INFORMATION_SCHEMA.PLUGINS WHERE PLUGIN_NAME LIKE '%ldap%';\""

echo "If the plugin is installed, then create the user by executing: mysql -uroot -p -e \"CREATE USER 'basha'@'localhost' IDENTIFIED WITH authentication_ldap_simple AS 'uid=basha,ou=People,dc=support,dc=local';\""

echo "Last, connect as the user by executing mysql --user=basha --password --enable-cleartext-plugin" 
