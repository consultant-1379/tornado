#!/bin/bash

# Change directory to where this script is located
# Given the above assumption, all path are local ones
cd $(dirname $(readlink -f $0))

echo "This script is meant to pull the Container images from the Red Hat CDN, hence a valid subscription must be enrolled to the system."

sudo subscription-manager status >/dev/null 2>&1
if [[ "$?" != "0" ]]; then
  echo "subscription-manager returned an error"
  sudo subscription-manager status
  exit 1
fi

_THT="/usr/share/openstack-tripleo-heat-templates"
_LTHT="../overcloud"

source ~/stackrc

rm -f /home/stack/overcloud_images.yaml

sudo -E openstack overcloud container image prepare \
  --namespace=registry.access.redhat.com/rhosp13 \
  --push-destination=$(ip -4 -o address show br-ctlplane|awk '{print $4}'|sed "s/\/.*$//g"):8787 \
  --prefix=openstack- \
  --tag-from-label {version}-{release} \
  --set ceph_namespace=registry.access.redhat.com/rhceph \
  --set ceph_image=rhceph-3-rhel7 \
  --output-env-file=/home/stack/overcloud_images.yaml \
  --output-images-file /home/stack/local_registry_images.yaml \
  -e ${_THT}/environments/debug.yaml \
  -e ${_THT}/environments/sshd-banner.yaml \
  -e ${_THT}/environments/network-isolation.yaml \
  -e ${_THT}/environments/host-config-and-reboot.yaml \
  -e ${_THT}/environments/services-docker/cinder-backup.yaml \
  -e ${_THT}/environments/services-docker/octavia.yaml \
  -e ${_THT}/environments/services-docker/neutron-ovn-dvr-ha.yaml \
  -e ${_THT}/environments/compute-instanceha.yaml \
  -e ${_LTHT}/environments/05-ssl-ca-cert.yaml \
  -e ${_LTHT}/environments/05-ssl-tls-cert.yaml \
  -e ${_LTHT}/environments/05-endpoints-public-dns.yaml \
  -e ${_LTHT}/environments/10-commons-parameters.yaml \
  -e ${_LTHT}/environments/20-network-environment.yaml \
  -e ${_LTHT}/environments/30-unity-storage-environment.yaml \
  -e ${_LTHT}/environments/40-fencing.yaml \
  -e ${_LTHT}/environments/50-keystone-admin-endpoint.yaml \
  -e ${_LTHT}/environments/60-openstack-neutron-custom-configs.yaml \
  -e ${_LTHT}/environments/65-openstack-nova-custom-configs.yaml \
  -e ${_LTHT}/environments/70-standard-performance.yaml \
  -e ${_LTHT}/environments/70-high-performance.yaml \
  -e ${_LTHT}/environments/99-extraconfig.yaml

# due to https://bugzilla.redhat.com/show_bug.cgi?id=1597646
sudo chown stack:stack /home/stack/local_registry_images.yaml

sudo -E openstack overcloud container image upload \
  --config-file  /home/stack/local_registry_images.yaml \
  --verbose

# due to https://bugzilla.redhat.com/show_bug.cgi?id=1597646
sudo chown stack:stack /home/stack/overcloud_images.yaml

curl -s $(ip -4 -o address show br-ctlplane|awk '{print $4}'|sed "s/\/.*$//g"):8787/v2/_catalog|jq .
rm -f /home/stack/local_registry_images.yaml

exit 0
