#!/bin/bash

echo ###############
echo CREATING CONFIG...
sed -e "s/##ca##/my-ca/g" config-templates/ca.cnf > config/my-ca.cnf || exit 1
sed -i -e "s/##dn##/my-ca/g" config/my-ca.cnf || exit 1
echo ###############
echo GENERTATING KEY...
openssl genrsa -out private/my-ca.key 2048 || exit 1
echo ###############
echo GENERTATING CERTIFICATE...
openssl req -batch -config config/my-ca.cnf -key private/my-ca.key -new -x509 -days 3650 -sha256 -extensions v3_ca -out certs/my-ca.crt || exit 1
openssl x509 -noout -text -in certs/my-ca.crt || exit 1
echo ###############
echo GENERTATING DATABASES...
touch db/my-ca.db || exit 1
echo "unique_subject = yes" > db/my-ca.db.attr || exit 1
echo 0001 > db/my-ca.serial || exit 1

