#!/bin/bash

for environment in $environments
do
	echo ###############
	echo GENERATING INTERMEDIATE CA FOR $environment ENVIRONMENT

	echo ###############
	echo CREATING CONFIG...
	sed -e "s/##ca##/my-ca\.intermediate-$environment/g" config-templates/ca.cnf > config/my-ca.intermediate-$environment.cnf || exit 1
	sed -i -e "s/##dn##/my-ca\.intermediate-$environment/g" config/my-ca.intermediate-$environment.cnf || exit 1
	
	echo ###############
	echo GENERTATING KEY
	openssl genrsa -out private/my-ca.intermediate-$environment.key 2048 || exit 1
	
	echo ###############
	echo GENERTATING CSR...
	openssl req -batch -config "config/my-ca.intermediate-$environment.cnf" -new -sha256 -key "private/my-ca.intermediate-$environment.key" -out "csr/my-ca.intermediate-$environment.csr" || exit 1

	echo ###############
	echo SIGNING CSR...
	openssl ca -batch -config config/my-ca.cnf -extensions v3_intermediate_ca -days 1825 -notext -md sha256 -in "csr/my-ca.intermediate-$environment.csr" -out "certs/my-ca.intermediate-$environment.crt" || exit 1
	cat certs/my-ca.intermediate-$environment.crt certs/my-ca.crt > certs/my-ca.intermediate-$environment.chain.crt || exit 1
	# openssl pkcs12 -export -nodes -passout pass:rf -out certs/my-ca.intermediate-$environment.pfx -inkey private/my-ca.intermediate-$environment.key -in certs/my-ca.intermediate-$environment.crt -certfile certs/my-ca.crt || exit 1

	echo ##############################
	echo VERIFYING CERTIFICATES...
	openssl x509 -noout -text -in certs/my-ca.crt || exit 1
	openssl verify -CAfile certs/my-ca.crt certs/my-ca.intermediate-$environment.crt || exit 1

	echo ###############
	echo CREATING DATABASES...
	touch db/my-ca.intermediate-$environment.db
	echo "unique_subject = yes" > db/my-ca.intermediate-$environment.db.attr
	echo 0001 > db/my-ca.intermediate-$environment.serial
done