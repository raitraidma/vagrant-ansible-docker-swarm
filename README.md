# Vagrant Ansible Docker Swarm

This is an example, how to create Docker Swarm using Vagrant and Ansible.

Ansible's VM is created, so you do not have to install Ansible in your host machine.

`key.private` and `key.public` are used to enable Ansible to connecto to other machines - you can generate you own key pair.

## Prerequisites
* [VirtualBox](https://www.virtualbox.org/)
* [Vagrant](https://www.vagrantup.com/)

## Create Docker Swarm

Create VMs:
```sh
vagrant up
```

Login to Ansible's virtual machine (172.16.66.10:22 or 127.0.0.1:2210 with username `vagrant` and password `vagrant`; or `vagrant ssh`) and execute following commands:
```sh
cd /vagrant
ansible-playbook playbook.yml -i inventory -e @vars.yml
```
