HOSTNAME=cloud12a.athtem.eei.ericsson.se
openssl req -new -newkey rsa:2048 -nodes -out ${HOSTNAME}.csr -keyout ${HOSTNAME}.key -subj "/C=SE/ST=Stockholm/L=Stockholm/O=Ericsson/OU=IT SERVICES/CN=${HOSTNAME}"
