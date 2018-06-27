#!/bin/bash

for environment in $environments
do
	client_name="$environment.client"
	echo ###############
	echo "GENERATING CLIENT CERTIFICATE FOR $client_name"

	echo ###############
	echo GENERTATING KEY...
	openssl genrsa -out private/$client_name.key 2048 || exit 1

	echo ###############
	echo CREATING CONFIG...
	sed -e "s/##ca##/my-ca\.intermediate-$environment/g" config-templates/ca.cnf > config/$client_name.cnf || exit 1
	sed -i -e "s/##dn##/$client_name/g" config/$client_name.cnf || exit 1

	echo ###############
	echo GENERTATING CSR...
	openssl req -batch -config "config/$client_name.cnf" -key "private/$client_name.key" -new -sha256 -out "csr/$client_name.csr" || exit 1

	echo ###########
	echo SIGNING CSR...
	openssl ca -batch -config "config/$client_name.cnf" -extensions client_cert -days 1825 -notext -md sha256 -in "csr/$client_name.csr" -out "certs/$client_name.crt" || exit 1
	openssl x509 -noout -text -in "certs/$client_name.crt" || exit 1
	openssl verify -CAfile "certs/my-ca.intermediate-$environment.chain.crt" "certs/$client_name.crt" || exit 1
	openssl pkcs12 -export -nodes -passout pass:rf -out "certs/$client_name.pfx" -inkey "private/$client_name.key" -in "certs/$client_name.crt" -certfile certs/my-ca.intermediate-$environment.crt || exit 1

done

