# Vagrant Ansible Docker Swarm

This is an example, how to create Docker Swarm using Vagrant and Ansible.

Ansible's VM is created, so you do not have to install Ansible in your host machine.

`key.private` and `key.public` are used to enable Ansible to connect to other machines - you can generate you own key pair.

## Prerequisites
* [VirtualBox](https://www.virtualbox.org/)
* `vagrant plugin install vagrant-vbguest`
* [Vagrant](https://www.vagrantup.com/)

## Create Docker Swarm

Create VMs:
```sh
vagrant up
```

This command creates 4 machines:
- `ansible` (provisioner)
- `swarm-node-1` (manager)
- `swarm-node-2` (worker)
- `swarm-node-3` (worker)

Login to `ansible` virtual machine (172.16.66.10:22 or 127.0.0.1:2210 with username `vagrant` and password `vagrant`; or `vagrant ssh ansible`) and execute following commands:
```sh
cd /vagrant
./setup.sh
```

## Management and monitoring

### Monitoring Docker Swarm with Portainer, Visualizer, cAdvisor, InfluxDB and Grafana

Instructions about cAdvisor, InfluxDB and Grafana are taken form:
https://botleg.com/stories/monitoring-docker-swarm-with-cadvisor-influxdb-and-grafana/
Github: https://github.com/botleg/swarm-monitoring

Login to `swarm-node-1` virtual machine (172.16.66.11:22 or 127.0.0.1:2211 with username `vagrant` and password `vagrant`; or `vagrant ssh swarm-node-1`) and execute following commands:
```sh
cd /vagrant
./deploy.sh
```

Run `docker stack services monitoring` and verify if all services have all replicas up and running. If not, then wait and look again.

#### Create database to InfluxDB
```sh
docker exec `docker ps | grep -i influx | awk '{print $1}'` influx -execute 'CREATE DATABASE cadvisor'
```

#### Create dashboard in Grafana
Open http://127.0.0.1:9002 or http://172.16.66.11:9002

Default username and password are `admin` and `admin`

Create a new data source:
- Name: `InfluxDB`
- Type: `InfluxDB`
- Url: `http://influx:8086`
- Database: `cadvisor`.

Finally import the `dashboard.json`: click on the logo on the upper left corner -> `Dashboards` -> `Import` -> Import `dashboard.json` -> Select `InfluxDB data source`

### GUIs:
- Portainer: http://127.0.0.1:9000
- Visualizer: http://127.0.0.1:9001
- Grafana: http://127.0.0.1:9002