#!/bin/bash

echo "Upload and update Dell-EMC Unity docker image"
echo -n "Red Hat CDN Username: "
read _USERNAME
echo -n "Red Hat CDN Password: "
read -s _PASSWORD

docker login -u ${_USERNAME} -p ${_PASSWORD} registry.connect.redhat.com
docker pull registry.connect.redhat.com/dellemc/openstack-cinder-volume-dellemc

docker tag registry.connect.redhat.com/dellemc/openstack-cinder-volume-dellemc $(ip -4 -o address show br-ctlplane|awk '{print $4}'|sed "s/\/.*$//g"):8787/dellemc/openstack-cinder-volume-dellemc
docker push $(ip -4 -o address show br-ctlplane|awk '{print $4}'|sed "s/\/.*$//g"):8787/dellemc/openstack-cinder-volume-dellemc

sed -e "s/rhosp13\/openstack-cinder-volume.*$/dellemc\/openstack-cinder-volume-dellemc:latest/g" -i /home/stack/overcloud_images.yaml

exit 0
