# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# LICENSE UPL 1.0
#
# Copyright (c) 1982-2018 Oracle and/or its affiliates. All rights reserved.
# 
# Since: January, 2018
# Author: gerald.venzl@oracle.com
# Description: Creates an Oracle Linux virtual machine.
# 
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
# 

VAGRANTFILE_API_VERSION = "2"

unless Vagrant.has_plugin?("vagrant-reload")
  puts 'Installing vagrant-reload Plugin...'
  system('vagrant plugin install vagrant-reload')
end

unless Vagrant.has_plugin?("vagrant-vbguest")
  puts 'Installing vagrant-vbguest Plugin...'
  system('vagrant plugin install vagrant-vbguest')
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vbguest.auto_update = false 
  config.vm.provider "virtualbox" do |v|
    v.memory = 4096
  end
  config.vm.synced_folder ".", "/vagrant"
  vagrant_root = File.dirname(__FILE__)
  ENV['ANSIBLE_ROLES_PATH'] = "#{vagrant_root}/.."
  ENV['ANSIBLE_NOCOWS'] = "1"

  $set_hosts = <<-SCRIPT
  echo '192.168.232.25 mysql1' >> /etc/hosts
  echo '192.168.232.26 mysql2' >> /etc/hosts
  echo '192.168.232.27 mysql3' >> /etc/hosts
  echo '192.168.232.28 slapd'  >> /etc/hosts
  SCRIPT
  config.vm.provision "hosts", type: "shell", inline: $set_hosts, run: "once"
  
  $make_ansible_roles_directory= <<-SCRIPT
    mkdir /etc/ansible/roles -p
    chmod o+w /etc/ansible/roles
  SCRIPT
  config.vm.provision "ansible_roles_dir", type: "shell", inline: $make_ansible_roles_directory, run: "never"
  
  $install_mysql_server = <<-SCRIPT
  mysql_server_package=/vagrant/packages/p30754418_580_Linux-x86-64.zip
  yum install -y unzip
  unzip $mysql_server_package
  yum install -y mysql-commercial-{server,client,common,libs}-*
  rm -f *.rpm
  SCRIPT
  config.vm.provision "mysql_server", type: "shell", inline: $install_mysql_server, run: "never"
  
  $install_mysql_shell = <<-SCRIPT
  mysql_shell_package=/vagrant/packages/mysql_shell/p30752665_800_Linux-x86-64.zip
  yum install -y unzip
  unzip $mysql_shell_package
  yum install -y mysql-shell-commercial*
  rm -f *.rpm
  SCRIPT
  config.vm.provision "mysql_shell", type: "shell", inline: $install_mysql_shell, run: "never"
  
  config.vm.define "mysql1", primary: true do |mysql1| 
    mysql1.vbguest.auto_update = false 
    mysql1.vm.box = "oraclelinux/7"
    mysql1.vm.box_url = "https://oracle.github.io/vagrant-boxes/boxes/oraclelinux-7.json"
    mysql1.vm.box_check_update = true 
    MYSQL1_IP = "192.168.232.25"
    MYSQL1_NAME = "mysql1" 
    mysql1.vm.network "private_network", ip: MYSQL1_IP, virtualbox__intnet: true
    mysql1.vm.hostname = MYSQL1_NAME 
    mysql1.vm.provision "shell", path: "provisioners/scripts/install.sh", run: "once"
    mysql1.vm.provision :reload, run: "once"
    mysql1.vm.provision "shell", inline: "echo 'INSTALLER: Installation complete, Oracle Linux 7 ready to use!'",
    run: "once"
  end

  config.vm.define "mysql2" do |mysql2| 
    mysql2.vbguest.auto_update = false 
    mysql2.vm.box = "oraclelinux/7"
    mysql2.vm.box_url = "https://oracle.github.io/vagrant-boxes/boxes/oraclelinux-7.json"
    mysql2.vm.box_check_update = true 
    MYSQL2_IP = "192.168.232.26"
    MYSQL2_NAME = "mysql2" 
    mysql2.vm.network "private_network", ip: MYSQL2_IP, virtualbox__intnet: true
    mysql2.vm.hostname = MYSQL2_NAME 
    mysql2.vm.provision "shell", path: "provisioners/scripts/install.sh", run: "once"
    mysql2.vm.provision :reload, run: "once"
    mysql2.vm.provision "shell", inline: "echo 'INSTALLER: Installation complete, Oracle Linux 7 ready to use!'",
    run: "once"
  end
  
  config.vm.define "mysql3" do |mysql3| 
    mysql3.vbguest.auto_update = false 
    mysql3.vm.box = "oraclelinux/7"
    mysql3.vm.box_url = "https://oracle.github.io/vagrant-boxes/boxes/oraclelinux-7.json"
    mysql3.vm.box_check_update = true 
    MYSQL3_IP = "192.168.232.27"
    MYSQL3_NAME = "mysql3" 
    mysql3.vm.network "private_network", ip: MYSQL3_IP, virtualbox__intnet: true
    mysql3.vm.hostname = MYSQL3_NAME 
    mysql3.vm.provision "shell", path: "provisioners/scripts/install.sh", run: "once"
    mysql3.vm.provision :reload, run: "once"
    mysql3.vm.provision "shell", inline: "echo 'INSTALLER: Installation complete, Oracle Linux 7 ready to use!'",
    run: "once"
  end
  
  config.vm.define "mysql4", primary: true do |mysql4| 
    mysql4.vm.box = "ubuntu/bionic64"
    #mysql4.vm.box_url = ""
    #mysql4.vm.box_check_update = true 
    mysql4.vbguest.auto_update = false 
    MYSQL4_IP = "192.168.232.28"
    MYSQL4_NAME = "mysql4" 
    mysql4.vm.network "private_network", ip: MYSQL4_IP, virtualbox__intnet: true
    mysql4.vm.hostname = MYSQL4_NAME 
  end
  
  config.vm.define "mysqlwin" do |mysqlwin|
    mysqlwin.vm.box = "mwrock/Windows2012R2"
  end

  config.vm.define "slapd" do |slapd|
    slapd.vbguest.auto_update = true
    SLAPD_IP = "192.168.232.29"
    SLAPD_NAME = "slapd"
    slapd.vm.network "private_network", ip: SLAPD_IP, virtualbox__intnet: true
    slapd.vm.hostname = SLAPD_NAME
    #slapd.vm.provision 'others-write', type: :shell, inline: <<~'EOM'
    #  mkdir /etc/ansible/roles -p
    #  chmod o+w /etc/ansible/roles
    #EOM
    slapd.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "provisioners/ansible/slapd.yml"
    end
    slapd.vm.provision "ldap-person", type: "shell", run: "never", path: "provisioners/scripts/slapd_person.sh"
  end

end
