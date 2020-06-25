#!/bin/bash

cat >passfile <<EOM
someGoodPassword
EOM
CAHOST=$(hostname)
SERVERHOST=hod06
CLIENTHOST=hod05

answersCA() {
        echo IE
        echo Leinster
        echo Dublin
        echo Totally no Robots Inc
        echo Human Relations
        echo $HOST
        echo root@$HOST
}

answersCLIENT() {
        echo IE
        echo Leinster
        echo Dublin
        echo Totally no Robots Inc
        echo Human Relations
        echo $CLIENTHOST
        echo root@$HOST
        echo 
        echo 
        echo y
        echo y
}
answersSERVER() {
        echo IE
        echo Leinster
        echo Dublin
        echo Totally no Robots Inc
        echo Human Relations
        echo $SERVERHOST
        echo root@$HOST
        echo 
        echo 
        echo y
        echo y
}

#         answers | /usr/bin/openssl req -newkey rsa:2048 -keyout $PEM1 -nodes -x509 -days 365 -out $PEM2 2> /dev/null


DIR=/home/rmcglue/mysql-makecerts/rmcglue-openssl
rm -rf $DIR/*
PRIV=$DIR/private

mkdir -p $DIR $PRIV $DIR/newcerts
#cp /usr/share/ssl/openssl.cnf $DIR
if [ ! -e $DIR/openssl.cnf ];then
	echo file doesnt exist
	cp /etc/pki/tls/openssl.cnf $DIR
fi
#echo $DIR

ls -l $DIR/openssl.cnf
sed -i "s|^dir.*|dir	= $DIR|g" $DIR/openssl.cnf
echo sed -i "s/demoCA/$DIR/g" $DIR/openssl.cnf
# replace ./demoCA $DIR -- $DIR/openssl.cnf

# Create necessary files: $database, $serial and $new_certs_dir
# directory (optional)

touch $DIR/index.txt
echo "01" > $DIR/serial

#
# Generation of Certificate Authority(CA)
echo STEP 1:
echo ==========
echo Generation of Certificate Authority\(CA\)
#


answersCA | openssl req -new -x509 -passout file:passfile -keyout $PRIV/cakey.pem -out $DIR/ca.pem -days 3600 -config $DIR/openssl.cnf  > /dev/null 2>&1 
echo
echo openssl req -new -x509 -passout file:passfile -keyout $PRIV/cakey.pem -out $DIR/ca.pem -days 3600 -config $DIR/openssl.cnf 
#openssl req -new -x509 -keyout $PRIV/cakey.pem -out $DIR/ca.pem -days 3600 -config $DIR/openssl.cnf


for i in server client;do
#
# Create $i request and key
echo  Create $i request and key
#
if [ $i == "server" ];then
answersSERVER | openssl req -new -passout file:passfile -keyout  $DIR/$i-key.pem -out $DIR/$i-req.pem -days 3600 -config $DIR/openssl.cnf     > /dev/null 2>&1 
else
answersCLIENT | openssl req -new -passout file:passfile -keyout  $DIR/$i-key.pem -out $DIR/$i-req.pem -days 3600 -config $DIR/openssl.cnf     > /dev/null 2>&1
fi

echo
echo openssl req -new -passout file:passfile -keyout  $DIR/$i-key.pem -out $DIR/$i-req.pem -days 3600 -config $DIR/openssl.cnf
#
# Remove the passphrase from the key
echo Remove the passphrase from the key
#
openssl rsa -passin file:passfile -in $DIR/$i-key.pem -out $DIR/$i-key.pem

#
# Sign $i cert
 echo Sign $i cert
#
# openssl  -passin file:passfile  ca -cert $DIR/ca.pem -policy policy_anything     -out $DIR/$i-cert.pem -config $DIR/openssl.cnf     -infiles $DIR/$i-req.pem > /dev/null 2>&1
echo openssl  ca -passin file:passfile   -cert $DIR/ca.pem -policy policy_anything     -out $DIR/$i-cert.pem -config $DIR/openssl.cnf     -infiles $DIR/$i-req.pem 
openssl  ca -batch -passin file:passfile   -cert $DIR/ca.pem -policy policy_anything     -out $DIR/$i-cert.pem -config $DIR/openssl.cnf     -infiles $DIR/$i-req.pem 

# 1 out of 1 certificate requests certified, commit? [y/n]y
# Write out database with 1 new entries
# Data Base Updated

ls -l $DIR/ca.pem $DIR/$i-cert.pem $DIR/$i-req.pem $DIR/$i-key.pem $DIR/client-cert.pem $DIR/client-req.pem $DIR/client-key.pem 
done


#
# Create a my.cnf file that you can use to test the certificates
#

cat <<EOF > $DIR/my.cnf
[client]
ssl-ca=$DIR/ca.pem
ssl-cert=$DIR/client-cert.pem
ssl-key=$DIR/client-key.pem
[mysqld]
ssl_ca=$DIR/ca.pem
ssl_cert=$DIR/$i-cert.pem
ssl_key=$DIR/$i-key.pem
EOF
