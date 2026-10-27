# Cloud init

## Table of content

- [Cloud init](#cloud-init)
  - [Table of content](#table-of-content)
  - [Deploy cloud-init01 vm for test](#deploy-cloud-init01-vm-for-test)
  - [Ubuntu 26.04 MySQL with  post cloud-init](#ubuntu-2604-mysql-with--post-cloud-init)



## Deploy cloud-init01 vm for test

```bash
mkdir -p scripts_kvm_cloud_init/ubuntu_26.04
cd scripts_kvm_cloud_init/ubuntu_26.04

# paste content
sudo nano create-ubuntu-cloud-init01.sh
# paste content
sudo nano user-data.yaml

bash create-ubuntu-cloud-init01.sh

```

Log from script and selections in serial installer

```log
IP address 10.68.68.60 is available.
Do you want to proceed with VM creation? [y/N]:y

Continue in rich mode

```


## Ubuntu 26.04 MySQL with  post cloud-init

With Ubuntu 26.04 LTS ("Resolute Raccoon"), Canonical integrated the MySQL 8.4 LTS Community edition binaries straight into the official core resolute-updates/main repository

This inclusion significantly simplifies infrastructure-as-code and orchestration setups like cloud-init on KVM, as you no longer need to deal with Oracle's external APT repository configuration.

```yml
```

Run cloud init.

```Bash

```

```bash
ssh master@10.68.68.60
```



