#!/usr/bin/env bash

## https://www.golinuxcloud.com/install-and-configure-openldap-centos-7-linux/#Replace_olcSuffix_and_olcRootDN_attribute ##

ADMIN_PASSWD=ldapadmpass
BASHA_PASSWD=password123
#SLAPDROOTPASS=$(slappasswd -h {SSHA} -s $ADMIN_PASSWD)

DB_LDIF=/vagrant/provisioners/scripts/etc/local_support_admin.ldif
PEOPLE_LDIF=/vagrant/provisioners/scripts/etc/local_support_people.ldif
BASHA_LDIF=/vagrant/provisioners/scripts/etc/local_support_people_basha.ldif

#sed -i "s/%SLAPDROOTPASS%/$SLAPDROOTPASS/" $DB_LDIF

slapcat -n 0 -a '(olcSuffix=*)' | egrep 'Suffix|olcDatabase'
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif 
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif

ldapmodify -Y EXTERNAL -H ldapi:/// -f $DB_LDIF 
ldapadd -x -w ldapadmpass -D "cn=ldapadm,dc=support,dc=local" -f $PEOPLE_LDIF
ldapadd -x -w ldapadmpass -D "cn=ldapadm,dc=support,dc=local" -f $BASHA_LDIF
ldappasswd -s $BASHA_PASSWD -w $ADMIN_PASSWD -D "cn=ldapadm,dc=support,dc=local" -x "uid=basha,ou=People,dc=support,dc=local"

#echo 'Try:  ldapsearch -x -w ldapadmpass -D "cn=ldapadm,dc=support,dc=local" -b "dc=support,dc=local" "(objectclass=*)"' 
