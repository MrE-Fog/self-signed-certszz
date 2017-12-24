#!/bin/bash
#
# generates a root ca certificate
#

# cert validity in days
DAYS=9999

# remove old keys
test -f root_ca.key && rm root_ca.key root_ca.pem

# generate key
openssl genrsa -des3 \
  -passout "file:root_ca.pass" \
  -out root_ca.key 4096

# create certificate
openssl req -x509 -new -nodes \
  -days $DAYS \
  -config root_ca.ini \
  -passin "file:root_ca.pass" \
  -key root_ca.key -out root_ca.pem

# show certificate
openssl x509 -text -noout -in root_ca.pem
