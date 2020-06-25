#!/usr/bin/env bash

#config_fqdn=$(hostname --fqdn)
#config_domain=$(hostname --domain)
#config_domain_dc="dc=$(echo $config_domain | sed 's/\./,dc=/g')"
config_admin_dn="cn=admin,cn=config"
config_admin_password=ldapadmpass

# create the people container.
ldapadd -D $config_admin_dn -w $config_admin_password <<EOF
dn: ou=people,$config_domain_dc
objectClass: organizationalUnit
ou: people
EOF

# add people.
function add_person {
    local n=$1; shift
    local name=$1; shift
    ldapadd -D $config_admin_dn -w $config_admin_password <<EOF
dn: uid=$name,ou=people,$config_domain_dc
objectClass: inetOrgPerson
userPassword: $(slappasswd -s password)
uid: $name
mail: $name@$config_domain
cn: $name doe
givenName: $name
sn: doe
telephoneNumber: +1 888 555 000$((n+1))
labeledURI: http://example.com/~$name Personal Home Page
EOF
}
people=(betsy, boris)
for n in "${!people[@]}"; do
    add_person $n "${people[$n]}"
done
#jpegPhoto::$(base64 -w 66 /vagrant/avatars/avatar-$n.jpg | sed 's,^, ,g')

# show the configuration tree.
ldapsearch -Q -LLL -Y EXTERNAL -H ldapi:/// -b cn=config dn | grep -v '^$'

# show the data tree.
ldapsearch -x -LLL -b $config_domain_dc dn | grep -v '^$'

# search for people and print some of their attributes.
ldapsearch -x -LLL -b $config_domain_dc '(objectClass=person)' cn mail
