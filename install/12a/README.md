# Ericsson ITTE OSP13
## How to
### Use those templates
Those templates have been developed using the infra-as-code principles and for production environments scope.
The structure somehow diverges from the standard TripleO/OSPd baseline adding deterministic and reproducible environment limiting at the minimum and random allocation.
Knowledge about how those have been developed can be found in the Red Hat OpenStack Platform advanced configuration chapter
https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/13/html/advanced_overcloud_customization/

### Deploy a cloud
In order to deploy a cloud, the undercloud must be installed. No scripts are provided for this scope but the undercloud configuration is under versioning control.
Then moving into the script folder, in numerical order the various script must be executed.
Two optional scripts can be skipped. 
- 003-create_update_osp_images.sh -> The operator may want to use the standard Red Hat images without any modifications - recommended approach unless specific drivers/updates are required
- 009-openstack-cli-autocomplete.sh -> The bash auto completion may be an unwanted feature

### Apply incremental changes
Simply re-execute the 006-deploy_unity.sh script and then the 008-ansible-mysql-tuning.sh in order to re-apply the MySQL Tuning

### Why is called deploy-unity?
Eventually, Ericsson will try Red Hat Ceph Storage which required changes to those templates starting from the deployment script

### Use those templates as a baseline for a new cloud
Those templates rappresents the Ericsson ITTE OSP13 reference architecture. Usually changes between clouds can be found in the following files
 - The 003-create_update_osp_images.sh needs to point to the proper repository
 - 05-ssl-ca-cert.yaml -> Root CA
 - 05-ssl-tls-cert.yaml -> SSL certificate and key
 - 10-commons-parameters.yaml -> root password and cloud name
 - 20-network-environment.yaml -> Network details
 - 30-unity-storage-environment.yaml -> Unity confiuguration
 - 40-fencing.yaml -> MAC addreses and IPMI details

Also, if a new cloud is deployed without any HA compute node, the following changes need to be done:
- From the template '40-fencing.yaml' remove any reference to the compute nodes
- From the deployment script '006-deploy_unity.sh' remove the line including the 'compute-instanceha.yaml' template

### Sample host aggregates
Follows simple example for the host aggregates config in this environment having 4 compute node classes
```
openstack aggregate create --zone nova --property host=std standard
openstack aggregate add host standard overcloud-compute-std-0.localdomain
openstack aggregate add host standard overcloud-compute-std-1.localdomain
openstack flavor create --id 100 --vcpus 4 --ram 4096 --disk 40 --public --property host=std m1.std

openstack aggregate create --zone nova --property host=ha ha
openstack aggregate add host ha overcloud-compute-std-ha-0.localdomain
openstack aggregate add host ha overcloud-compute-std-ha-1.localdomain
openstack flavor create --id 200 --vcpus 4 --ram 4096 --disk 40 --public --property host=ha m1.ha

openstack aggregate create --zone nova --property host=hp hp
openstack aggregate add host hp overcloud-compute-hp-0.localdomain
openstack aggregate add host hp overcloud-compute-hp-1.localdomain
openstack flavor create --id 300 --vcpus 4 --ram 4096 --disk 40 --public --property host=hp \
  --property hw:cpu_policy='dedicated' \
  --property hw:mem_page_size='large' \
  m1.hp

openstack aggregate create --zone nova --property host=hp-ha hp-ha
openstack aggregate add host hp-ha overcloud-compute-hp-ha-0.localdomain
openstack aggregate add host hp-ha overcloud-compute-hp-ha-1.localdomain
openstack flavor create --id 400 --vcpus 4 --ram 4096 --disk 40 --public --property host=hp-ha \
  --property hw:cpu_policy='dedicated' \
  --property hw:mem_page_size='large' \
  m1.hp-ha
```

## Folder structure
```
├── overcloud		=> Overcloud main directory for custom templates and environment configuration
│   ├── environments	=> Templates and configurations for the platform (network, SSL, storage, tuning, and extraconfig hooks mapping)
│   ├── extraconfig	=> Pre and post-puppet customization hooks templates and scripts
│   │   ├── post-config	=> Post-puppet templates (e.g. configure Heat caching)
│   │   └── pre-config	=> Pre-puppet templates (e.g. install agents, NFS Shares)
│   ├── firstboot	=> Very first boot cutomization template (e.g. SSH root password)
│   └── nic-configs	=> Per role physical NIC mapping to bonds, vlan tags, subnets, and routes
├── scripts		=> Script directory including deployment and initialization scripts (e.g. Docker images, import baremetal environment)
├── playbooks		=> Ansible Playbook folder including customization playbook for the environment
├── ssl			=> Folder containing TLS certificate and Digicert Root and Intermediate Certificates
└── undercloud		=> Undercloud directory including undercloud configuration and baremetal environment
```
## File structure
```
├── README.md						=> This readme
├── overcloud
│   ├── environments					=> Main environment folder with all the templates describing the deployment
│   │   ├── 05-endpoints-public-dns.yaml		=> Template to enable DNS name for the External API
│   │   ├── 05-ssl-ca-cert.yaml				=> Ericsson Root CA
│   │   ├── 05-ssl-tls-cert.yaml			=> Ericsson Cloud12 x509 certificate and private key
│   │   ├── 10-commons-parameters.yaml			=> Common environment parameters (e.g. TimeZone, root password, SSH config, and DNS cloud name)
│   │   ├── 20-network-environment.yaml			=> Network template file defining subnets, vlans, allocation rangies, bonding setup, fixed IPs, Virtual IPs, etc
│   │   ├── 30-nfs-storage-environment.yaml		=> NFS storage configuration for all the services such as Glance Image, Glance Staging area, Gnocchi, Cinder Backup, and Nova Ephemeral Storage for the HA compute roles
│   │   ├── 30-unity-storage-environment.yaml		=> Dell-EMC Unity configuration such as IP, storage pool, auth credential, storage ports
│   │   ├── 40-fencing.yaml				=> Hash with server Ethernet MAC address, IPMI credential, and fencing mechanism
│   │   ├── 50-keystone-admin-endpoint.yaml		=> Expose Keystone Admin API over external network
│   │   ├── 60-openstack-neutron-custom-configs.yaml	=> Specific Neutron configuration such as MTU size, bridge mapping, security group firewall driver etc
│   │   ├── 65-openstack-nova-custom-configs.yaml	=> Specific Nova configuration such as Multipathd, scheduler filters etc
│   │   ├── 70-high-performance.yaml			=> Specific High Performance (including HA) compute configuration such as Tuned profile, CPU pinning, Huge Pages, kernel parameters, sysctl tunables etc
│   │   ├── 70-standard-performance.yaml		=> Specific Standard Performance (including HA) compute configuration such as sysctl tunables, reserved memory etc
│   │   └── 99-extraconfig.yaml				=> Puppet Extra configuration for Pre and Post deployment hooks, tuning (oslo, memcached, rabbit, haproxy, mysql) and also Nova Scheduler weights (cpu, disk, and memory) per compute role
│   ├── extraconfig
│   │   ├── post-config					=> Post deployment template folder currently only used by controller role to enable Heat cache and fix Gnocchi permissions over NFS
│   │   │   ├── controller.yaml
│   │   │   └── scripts
│   │   │       ├── fix_gnocchi_permission.sh
│   │   │       └── heatcache.sh
│   │   └── pre-config					=> Pre deployment template folder currently used by all compute and controller roles for NFS configuration, KSM, Multipath and vHost Net zero copy
│   │       ├── compute.yaml
│   │       ├── compute_ha.yaml
│   │       ├── compute_hp_ha.yaml
│   │       ├── controller.yaml
│   │       └── scripts
│   │           ├── ksm.sh
│   │           ├── multipathd.sh
│   │           ├── nfs.sh
│   │           └── vhost_net_zero_copy.sh
│   ├── firstboot
│   │   └── first-boot.yaml				=> First boot template for root SSH password
│   ├── network-data.yaml				=> Generic template used to define the NFS network (the template also has all other networks but it's not used for that scope)
│   ├── nic-configs
│   │   ├── compute.yaml				=> Compute NIC mapping templates
│   │   └── controller.yaml				=> Controller NIC mapping templates
│   ├── nodes-info.yaml					=> Node info such as quantity per node
│   └── roles-data.yaml					=> Roles template used to define additional compute roles
├── playbooks
│   └── mysql_tuning.yml				=> MySQL tunables Ansible playbook
├── scripts
│   ├── 001-install_digicert_root_undercloud.sh		=> Script to install the SSL root CA in the undercloud
│   ├── 002-import_instackenv_nodes.sh			=> Script to import the physical server into Ironic
│   ├── 003-create_update_osp_images.sh			=> OPTIONAL Script to create and update the overcloud RHEL images including all the latest RPMs
│   ├── 004-create_update_docker_osp_images.sh		=> Script to download the container images from the Red Hat DCN - active subscription required
│   ├── 005-create_update_docker_unity_image.sh		=> Script to download the Dell-EMC Unity container images from the Red Hat DCN - active subscription required
│   ├── 006-deploy_unity.sh				=> Script to deploy the platform
│   ├── 007-ansible-inventory.sh			=> Script to create the Ansible Inventory
│   ├── 008-ansible-mysql-tuning.sh			=> Script to enroll the MySQL Tuning
│   └── 009-openstack-cli-autocomplete.sh		=> OPTIONAL Script to install bash completion
├── ssl
│   ├── DigiCertSHA2SecureServerCA.cer
│   ├── DigiCert_Global_Root_CA.cer
│   ├── cloud12a.athtem.eei.ericsson.se.cer
│   ├── cloud12a.athtem.eei.ericsson.se.csr
│   ├── cloud12a.athtem.eei.ericsson.se.key
│   └── create_SSL_request.sh
└── undercloud
    ├── instackenv.json					=> Hardware definition
    └── undercloud.conf					=> Undercloud configuration
```
## Userful knowledge base
- Configure Docker to use a proxy with or without authentication
  https://access.redhat.com/solutions/1377973
- Misalignment Nova Placement API
  https://ask.openstack.org/en/question/115081/openstack-queen-instance-creation-error-no-valid-host-was-found/
- How to configure HTTP Proxy for Red Hat Subscription Management
  https://access.redhat.com/solutions/57669
- Ironic node using dracclient goes to clean failed with "Unfinished config jobs found"
  https://bugzilla.redhat.com/show_bug.cgi?id=1534551
- Nova instance provision fails with host is not mapped to any cell in Red Hat OpenStack Platform
  https://access.redhat.com/solutions/3268111
