# -*- mode: ruby -*-
# vi: set ft=ruby :

#Vagrant::Config.run do |config|
Vagrant.configure("2") do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  #config.vm.box = "leihs-1.0.1"
  #config.vm.box = "wheezy32"
  config.vm.box = "wheezy32-2.0.1" # Includes pip, necessary for Salt

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  # Use this base box if you want to rebuild the leihs box:
  config.vm.box_url = "http://www.psy-q.ch/stuff/wheezy32-2.0.1.box"
  #config.vm.box_url = "http://www.psy-q.ch/stuff/leihs-1.0.1.box"

  #config.vm.provision :shell, :path => "vagrant-bootstrap.sh"
  #config.vm.provision :salt do |salt|
  #  salt.minion_config = "salt/minion"
  #  salt.run_highstate = true
  #end



  # Boot with a GUI so you can see the screen. (Default is headless)
  # config.vm.boot_mode = :gui

  # Assign this VM to a host-only network IP, allowing you to access it
  # via the IP. Host-only networks can talk to the host machine as well as
  # any other machines on the same network, but cannot be accessed (through this
  # network interface) by any external networks.
  # config.vm.network :private_network, "192.168.33.10"

  # Assign this VM to a bridged network, allowing you to connect directly to a
  # network using the host's network device. This makes the VM appear as another
  # physical device on your network.
  config.vm.network :public_network
  config.vm.network :private_network, :ip => "192.168.10.10" # This is so Ansible or other provisioning systems can reach the host under a static IP

  config.vm.provision :ansible do |ansible|
    ansible.playbook = "ansible/vagrant.yml"
    ansible.inventory_file = "ansible/hosts"
    #ansible.sudo = true
    ansible.verbose = true
    #ansible.sudo_user = "vagrant"
  end

  # Forward a port from the guest to the host, which allows for outside
  # computers to access the VM, whereas host only networking does not.
  config.vm.network :forwarded_port, :guest => 80, :host => 8080, :auto_correct => true
  config.vm.network :forwarded_port, :guest => 5901, :host => 5901, :auto_correct => true
  config.vm.network :forwarded_port, :guest => 3000, :host => 3000, :auto_correct => true
  config.vm.network :forwarded_port, :guest => 3306, :host => 3306, :auto_correct => true

  # Let's give this thing 1 GB of memory
  config.vm.provider "virtualbox" do |vb|
     vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  #config.vm.synced_folder "salt/roots", "/srv/salt"

  # Share an additional folder to the guest VM. The first argument is
  # an identifier, the second is the path on the guest to mount the
  # folder, and the third is the path on the host to the actual folder.
  # config.vm.share_folder "v-data", "/vagrant_data", "../data"


end
