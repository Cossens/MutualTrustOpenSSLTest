#!/bin/bash

export environments="DEV
PROD"

export host_suffix="test.local"

./mkdir.sh
./clean.sh
./generate-root-ca.sh
./generate-intermediate-ca.sh
./generate-server-certs.sh
./generate-client-certs.sh