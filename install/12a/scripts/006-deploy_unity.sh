#!/bin/bash

# Change directory to where this script is located
# Given the above assumption, all path are local ones
cd $(dirname $(readlink -f $0))

source ~/stackrc

_THT="/usr/share/openstack-tripleo-heat-templates"
_LTHT="$(readlink -f ../overcloud)"

# Move to home folder to output the generared files during the deployment there
cd ~/

# Not possile to use "--environment-directory" due to https://bugzilla.redhat.com/show_bug.cgi?id=1593077

openstack overcloud deploy \
    --force-postconfig \
    --templates ${_THT} \
    --timeout 90 \
    -n ${_LTHT}/network-data.yaml \
    -r ${_LTHT}/roles-data.yaml \
    -e ${_LTHT}/nodes-info.yaml \
    -e ${_THT}/environments/debug.yaml \
    -e ${_THT}/environments/sshd-banner.yaml \
    -e ${_THT}/environments/network-isolation.yaml \
    -e ${_THT}/environments/host-config-and-reboot.yaml \
    -e ${_THT}/environments/services-docker/cinder-backup.yaml \
    -e ${_THT}/environments/services-docker/octavia.yaml \
    -e ${_THT}/environments/services-docker/neutron-ovn-dvr-ha.yaml \
    -e ${_THT}/environments/compute-instanceha.yaml \
    -e ~/overcloud_images.yaml \
    -e ${_LTHT}/environments/05-ssl-ca-cert.yaml \
    -e ${_LTHT}/environments/05-ssl-tls-cert.yaml \
    -e ${_LTHT}/environments/05-endpoints-public-dns.yaml \
    -e ${_LTHT}/environments/10-commons-parameters.yaml \
    -e ${_LTHT}/environments/20-network-environment.yaml \
    -e ${_LTHT}/environments/30-unity-storage-environment.yaml \
    -e ${_LTHT}/environments/30-nfs-storage-environment.yaml \
    -e ${_LTHT}/environments/40-fencing.yaml \
    -e ${_LTHT}/environments/50-keystone-admin-endpoint.yaml \
    -e ${_LTHT}/environments/60-openstack-neutron-custom-configs.yaml \
    -e ${_LTHT}/environments/65-openstack-nova-custom-configs.yaml \
    -e ${_LTHT}/environments/70-standard-performance.yaml \
    -e ${_LTHT}/environments/70-high-performance.yaml \
    -e ${_LTHT}/environments/99-extraconfig.yaml

exit 0
