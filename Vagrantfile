# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

current_dir    = File.dirname(File.expand_path(__FILE__))
config         = YAML.load_file("#{current_dir}/config.yaml")
vagrant_config = config['config']

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # For a complete vagrant documentation reference see: https://docs.vagrantup.com.

  config.vm.box = vagrant_config['vagrant_box']
  config.vm.box_version = vagrant_config['vagrant_box_version']

  config.vm.provision :shell, :inline => "echo Copying public ssh file from host to guest"
  config.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "~/.ssh/id_rsa.pub"

  config.vm.provision :shell, :inline => "echo Copying private ssh file from host to guest"
  config.vm.provision "file", source: "~/.ssh/id_rsa", destination: "~/.ssh/id_rsa"

  # File must be copied first to user directory because file provisioning does not support sudo
  config.vm.provision :shell, :inline => "echo Copying " + vagrant_config['project_name'] + " vhost file"
  config.vm.provision "file", source: "./templates/dev.projectname.com.conf", destination: "~/dev.projectname.com.conf"
  # Replace project name with variabele project_name in the vhost file
  config.vm.provision "shell", inline: "sed -i -e 's/projectname/" + vagrant_config['project_name'] + "/g' /home/vagrant/dev.projectname.com.conf"
  config.vm.provision "shell", inline: "sudo mv /home/vagrant/dev.projectname.com.conf /etc/nginx/conf.d/dev." + vagrant_config['project_name'] + ".com.conf"

  # copy database to box
  config.vm.provision "file", source: "./data/database_import.sql", destination: "~/database_import.sql"

  # Set permissions needed for nginx
  config.vm.provision "shell", inline: "sudo chown root:root /etc/nginx/conf.d/dev." + vagrant_config['project_name'] + ".com.conf"
  config.vm.provision "shell", inline: "sudo chmod -R 777 /etc/nginx/conf.d/dev." + vagrant_config['project_name'] + ".com.conf"
  config.vm.provision "shell", inline: "sudo restorecon -v /etc/nginx/conf.d/dev." + vagrant_config['project_name'] + ".com.conf"

  config.vm.provision :shell, :inline => "echo Copying selinux config file"
  config.vm.provision "file", source: "./templates/selinux", destination: "~/selinux"
  config.vm.provision "shell", inline: "sudo mv /home/vagrant/selinux /etc/selinux/config"

  config.vm.provision :shell, :inline => "echo Copying hosts file"
  config.vm.provision "file", source: "./templates/hosts", destination: "~/hosts"
  config.vm.provision "shell", inline: "sudo mv /home/vagrant/hosts /etc/hosts"

  # Setup the git user credentials
  config.vm.provision :shell, :inline => "git config --global user.name \"" + vagrant_config['git_config_user_name'] + "\""
  config.vm.provision :shell, :inline => "git config --global user.email \"" + vagrant_config['git_config_user_email'] + "\""

  # Setup database
  config.vm.provision :shell, :inline => "echo Importing " + vagrant_config['project_name'] + " database and granting permissions to root user"
  config.vm.provision "shell", inline: "mysql < /home/vagrant/database_import.sql"
  config.vm.provision "shell", inline: "mysql -e \"GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'password' WITH GRANT OPTION;\""

  config.vm.network "private_network", ip: vagrant_config['private_box_ip']

  #make sure the correct timezone is set
  config.vm.provision :shell, :inline => "sudo rm /etc/localtime && sudo ln -s /usr/share/zoneinfo/" + vagrant_config['timezone'] + " /etc/localtime", run: "always"

  config.vm.provider "virtualbox" do |vb|
    # Customize the amount of memory on the VM:
    vb.memory = vagrant_config['memory']
    # Customize the amount of cpu's on the VM
	vb.cpus = vagrant_config['cpus']
  end

  Vagrant.configure("2") do |config|
    # forward ssh keys to box
    config.ssh.private_key_path = "~/.ssh/id_rsa"
    config.ssh.forward_agent = true
  end

  ENV["LC_ALL"] = "en_US.UTF-8"

  directory_name = "./project/"
  Dir.mkdir(directory_name) unless File.exists?(directory_name)

  if Dir['./project/*'].empty?
    config.vm.provision :shell, inline: <<-SHELL, privileged: false do |shell|
      ssh-keyscan bitbucket.org >> ~/.ssh/known_hosts
      ssh-keyscan github.com >> ~/.ssh/known_hosts
      git clone $1 "/var/www/htdocs/dev.$2.com/"
      cd "/var/www/htdocs/dev.$2.com/"
      SHELL
      shell.args = [vagrant_config['git_repo'], vagrant_config['project_name']]
    end
  end

  config.vm.provision "shell", inline: <<-SHELL, privileged: true
    setenforce 0
    service nginx restart
  SHELL

  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.vm.synced_folder './project', '/var/www/htdocs/dev.' + vagrant_config['project_name'] + '.com'
end
