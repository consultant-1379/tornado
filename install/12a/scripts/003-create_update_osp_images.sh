#!/bin/bash

_LREPO="/etc/yum.repos.d/rhosp13_snap20190215T105938.repo"

echo "#### Removing old image directory content"
rm -rf ~/images
mkdir ~/images

echo "#### Updating local overcloud image packages to the latest version"
sudo yum update -y rhosp-director-images rhosp-director-images-ipa
rpm -q libguestfs-tools >/dev/null 2>&1 || sudo yum install -y libguestfs-tools

echo "#### Extract new overcloud images"
cd ~/images
for i in /usr/share/rhosp-director-images/overcloud-full-latest-13.0.tar /usr/share/rhosp-director-images/ironic-python-agent-latest-13.0.tar; do tar -xvf $i; done

echo "#### Copying local repository to the overcloud image"
virt-copy-in -a overcloud-full.qcow2 ${_LREPO} /etc/yum.repos.d

echo "#### Updating overcloud image"
virt-customize -a overcloud-full.qcow2 --update

echo "#### SELinux Relabel"
virt-customize -a overcloud-full.qcow2 --selinux-relabel

echo "#### Uploading updated overcloud image to the Undercloud's Glance Registry"
source ~/stackrc
openstack overcloud image upload --image-path ~/images/ --update-existing
openstack overcloud node configure $(openstack baremetal node list -c UUID -f value)

exit 0
