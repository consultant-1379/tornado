#!/bin/bash

# Change directory to where this script is located
# Given the above assumption, all path are local ones
cd $(dirname $(readlink -f $0))

cat ../ssl/DigiCert_Global_Root_CA.cer | sudo tee /etc/pki/ca-trust/source/anchors/ca.crt.pem
cat ../ssl/DigiCertSHA2SecureServerCA.cer | sudo tee -a /etc/pki/ca-trust/source/anchors/ca.crt.pem
sudo update-ca-trust extract

exit 0
