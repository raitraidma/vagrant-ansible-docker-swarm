nodes = [
  { :hostname => 'ansible',       :ip => '172.16.66.10', :ram => 512,  :cpus => 1, :ssh => 2210, :ports => {}},
  { :hostname => 'swarm-node-1',  :ip => '172.16.66.11', :ram => 2048, :cpus => 1, :ssh => 2211, :ports => {9000 => 9000, 9001 => 9001, 9002 => 9002}},
  { :hostname => 'swarm-node-2',  :ip => '172.16.66.12', :ram => 2048, :cpus => 1, :ssh => 2212, :ports => {}},
  { :hostname => 'swarm-node-3',  :ip => '172.16.66.13', :ram => 2048, :cpus => 1, :ssh => 2213, :ports => {}}
]

Vagrant.configure("2") do |config|
  nodes.each do |node|
    config.vm.define node[:hostname] do |nodeconfig|
      nodeconfig.vm.box = "trusty64_2";
      nodeconfig.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"
      nodeconfig.vm.hostname = node[:hostname]
      nodeconfig.vm.network :private_network, ip: node[:ip], host_ip: "127.0.0.1"

      node[:ports].each do |src,dest|
        nodeconfig.vm.network :forwarded_port,
          guest: dest,
          host: src,
          host_ip: "127.0.0.1",
          auto_correct: true
      end

      nodeconfig.vm.provider :virtualbox do |vb|
        vb.customize [
          "modifyvm", :id,
          "--name", node[:hostname],
          "--memory", node[:ram].to_s,
          "--cpus", node[:cpus].to_s
        ]
      end

      nodeconfig.vm.network :forwarded_port,
        guest: 22,
        host: node[:ssh],
        id: "ssh",
        host_ip: "127.0.0.1",
        auto_correct: true

      # Adding public key for remote authentication if not exists
      config.vm.provision :shell, :inline => <<SCRIPT
        if grep -F -f /vagrant/key.public /home/vagrant/.ssh/authorized_keys; then
          echo GOOD Pubic key exsits: /home/vagrant/.ssh/authorized_keys
        else
          echo Adding public key: /home/vagrant/.ssh/authorized_keys
          cat /vagrant/key.public >> /home/vagrant/.ssh/authorized_keys && chmod 600 /home/vagrant/.ssh/authorized_keys
        fi
SCRIPT

      if node[:hostname] == 'ansible'
        config.vm.provision :shell, :inline => <<SCRIPT
          apt-get -y install software-properties-common
          apt-add-repository ppa:ansible/ansible
          apt-get -y update
          apt-get -y install ansible
          cp /vagrant/key.private /home/vagrant/.ssh/swarm && chmod 600 /home/vagrant/.ssh/swarm && chown vagrant:vagrant /home/vagrant/.ssh/swarm
SCRIPT
      end
    end
  end
end
