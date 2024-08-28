# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # Nombres de variables
  consulServer = "consulServer"
  consulNodeName1 = "consulNode1"
  consulNodeName2 = "consulNode2"


  if Vagrant.has_plugin? "vagrant-vbguest"
    config.vbguest.no_install  = true
    config.vbguest.auto_update = false
    config.vbguest.no_remote   = true
  end

  config.vm.define :consulServer do |consulServer|
    consulServer.vm.box = "bento/ubuntu-22.04"
    consulServer.vm.network :private_network, ip: "192.168.100.4"
    consulServer.vm.hostname = "consulServer"
    consulServer.vm.provision "shell", inline: <<-SHELL
      echo "CONSUL_SERVER_NAME=#{consulServer}" >> /tmp/envs
    SHELL
    consulServer.vm.provision "shell", path: "./scripts/consul.sh"
  end

  config.vm.define :consulNode1 do |consulNode1|
    consulNode1.vm.box = "bento/ubuntu-22.04"
    consulNode1.vm.network :private_network, ip: "192.168.100.5"
    consulNode1.vm.hostname = "consulNode1"
    consulNode1.vm.provision "shell", inline: <<-SHELL
      echo "CONSUL_SERVER_NAME=#{consulServer}" >> /tmp/envs
      echo "NODE_NAME=#{consulNodeName1}" >> /tmp/envs
    SHELL
    consulNode1.vm.provision "shell", path: "./scripts/consulNode.sh"
  end
  
  config.vm.define :consulNode2 do |consulNode2|
    consulNode2.vm.box = "bento/ubuntu-22.04"
    consulNode2.vm.network :private_network, ip: "192.168.100.6"
    consulNode2.vm.hostname = "consulNode2"
    consulNode2.vm.provision "shell", inline: <<-SHELL
      echo "CONSUL_SERVER_NAME=#{consulServer}" >> /tmp/envs
      echo "NODE_NAME=#{consulNodeName2}" >> /tmp/envs
    SHELL
    consulNode2.vm.provision "shell", path: "./scripts/consulNode.sh"
  end


end
