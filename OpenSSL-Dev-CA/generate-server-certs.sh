#!/bin/bash

#cat config/nginx.conf.head > nginx/nginx.conf

for environment in $environments
do
	server_host="$environment.$host_suffix"
	echo ###############
	echo "GENERATING SERVER CERTIFICATE FOR HOST $server_host"

	echo ###############
	echo GENERTATING KEY...
	openssl genrsa -out private/$server_host.key 2048 || exit 1

	echo ###############
	echo CREATING CONFIG...
	sed -e "s/##ca##/my-ca\.intermediate-$environment/g" config-templates/ca.cnf > config/$server_host.cnf || exit 1
	sed -i -e "s/##dn##/$server_host/g" config/$server_host.cnf || exit 1

	echo ###############
	echo GENERTATING CSR...
	openssl req -batch -config "config/$server_host.cnf" -key "private/$server_host.key" -new -sha256 -out "csr/$server_host.csr" || exit 1

	echo ###########
	echo SIGNING CSR...
	openssl ca -batch -config "config/$server_host.cnf" -extensions server_cert -days 1825 -notext -md sha256 -in "csr/$server_host.csr" -out "certs/$server_host.crt" || exit 1
	openssl x509 -noout -text -in "certs/$server_host.crt" || exit 1
	cat certs/$server_host.crt certs/my-ca.intermediate-$environment.crt certs/my-ca.crt > certs/$server_host.chain.crt
	openssl verify -CAfile "certs/my-ca.intermediate-$environment.chain.crt" "certs/$server_host.crt" || exit 1
	openssl pkcs12 -export -nodes -passout pass:rf -out "certs/$server_host.pfx" -inkey "private/$server_host.key" -in "certs/$server_host.crt" -certfile certs/my-ca.intermediate-$environment.crt || exit 1

	# echo ###########
	# echo GENERATING NGINX CONFIG...

	# sed -e "s/my-server/$server_host/g" config/nginx.server > config/nginx.server.$server_host || exit 1	
	# sed -i -e "s/cert-path/`pwd`\/certs/g" config/nginx.server.$server_host || exit 1	
	# sed -i -e "s/key-path/`pwd`\/private/g" config/nginx.server.$server_host || exit 1	
	# sed -i -e "s/wwwroot-path/`pwd`\/wwwroot/g" config/nginx.server.$server_host || exit 1	
	# sed -i -e "s/my-ca\.intermediate/my-ca\.intermediate-$environment/g" config/nginx.server.$server_host || exit 1	
	# cat config/nginx.$server_host >> nginx/nginx.conf
done

#cat config/nginx.conf.foot >> nginx/nginx.conf