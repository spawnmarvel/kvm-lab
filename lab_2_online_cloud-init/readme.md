# Cloud init

## Table of content

- [](#deploy-cloud-init01-vm-with-all-settings)
- [](#ubuntu-2604-mysql)



## Deploy cloud-init01 vm with all settings

```bash
mkdir -p scripts_kvm_cloud_init/ubuntu_26.04
cd scripts_kvm_cloud_init/ubuntu_26.04

# paste content
sudo nano create-ubuntu-cloud-init01.sh
# paste content
sudo nano user-data.yaml

bash create-ubuntu-cloud-init01.sh
```

## Verify all settings from user-data.yml

```bash
ssh master@10.68.68.60
```


## Ubuntu 26.04 MySQL with cloud-init

With Ubuntu 26.04 LTS ("Resolute Raccoon"), Canonical integrated the MySQL 8.4 LTS Community edition binaries straight into the official core resolute-updates/main repository

This inclusion significantly simplifies infrastructure-as-code and orchestration setups like cloud-init on KVM, as you no longer need to deal with Oracle's external APT repository configuration.

```yml
```

Run cloud init.

```Bash

```