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

## Management and monitoring
Example tools.

Login to Swarm primapy manager's machine (172.16.66.11) and execute:

### Install Portainer
```sh
sudo mkdir -p /data/portainer

docker service create \
    --name portainer \
    --publish 9000:9000 \
    --constraint 'node.role == manager' \
    --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
    --mount type=bind,src=/data/portainer,dst=/data \
    portainer/portainer \
    -H unix:///var/run/docker.sock
```

Open http://172.16.66.11:9000

### Install Docker Swarm Visualizer
```sh
docker run -it -d -p 9001:8080 -v /var/run/docker.sock:/var/run/docker.sock dockersamples/visualizer
```
... or to run in a swarm ...
```sh
docker service create \
  --name=viz \
  --publish=9001:8080/tcp \
  --constraint=node.role==manager \
  --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
  dockersamples/visualizer
```

Open http://172.16.66.11:9001

### Install cAdvisor
This has to be set up on every node that needs to be monitored.

```sh
docker run \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:rw \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --publish=9002:8080 \
  --detach=true \
  --name=cadvisor \
  google/cadvisor:latest
```

Open http://172.16.66.11:9002 (Shows info about containers that are in 172.16.66.11)

### Monitoring Docker Swarm with cAdvisor, InfluxDB and Grafana
Instructions from: https://botleg.com/stories/monitoring-docker-swarm-with-cadvisor-influxdb-and-grafana/

Github: https://github.com/botleg/swarm-monitoring

```sh
cd /vagrant
docker stack deploy -c docker-swarm-monitoring.yml monitor
```

Run `docker stack services monitor` and verify if all services have all replicas up and running. If not, then wait and look again.

Create database to InfluxDB:
```sh
docker exec `docker ps | grep -i influx | awk '{print $1}'` influx -execute 'CREATE DATABASE cadvisor'
```

Open http://172.16.66.11:80

Default username and password are `admin` and `admin`

In Grafana, create a new InfluxDB data source, with url `http://influx:8086` and database `cadvisor`.

Finally import the [dashboard](https://github.com/botleg/swarm-monitoring/blob/master/dashboard.json)