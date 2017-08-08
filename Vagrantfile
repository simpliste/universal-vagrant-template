# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

class ::Hash
  def deep_merge(second)
    merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : Array === v1 && Array === v2 ? v1 | v2 : [:undefined, nil, :nil].include?(v2) ? v1 : v2 }
    self.merge(second.to_h, &merger)
  end
end

current_dir       = File.dirname(File.expand_path(__FILE__))
config            = YAML.load_file("#{current_dir}/config.yaml")
box_config        = YAML.load_file("#{current_dir}/box/config.yaml")

vagrant_config    = box_config['config'].deep_merge(config['config'])
projects          = vagrant_config['projects']
known_hosts       = vagrant_config['known_hosts']
database_scripts  = vagrant_config['database_scripts']
copy_files        = vagrant_config['copy_files']
restart_services  = vagrant_config['restart_services']
commands          = vagrant_config['commands']

Vagrant.configure("2") do |config|
  # For a complete vagrant documentation reference see: https://docs.vagrantup.com.
  config.vm.box = vagrant_config['vagrant_box']
  config.vm.box_version = vagrant_config['vagrant_box_version']
  config.vm.network "private_network", ip: vagrant_config['private_box_ip']
  #make sure the correct timezone is set
  config.vm.provision :shell, :inline => "sudo rm /etc/localtime && sudo ln -s /usr/share/zoneinfo/" + vagrant_config['timezone'] + " /etc/localtime", run: "always"

  config.vm.provider "virtualbox" do |vb|
    # Customize the amount of memory on the VM:
    vb.memory = vagrant_config['memory']
    # Customize the amount of cpu's on the VM
    vb.cpus = vagrant_config['cpus']
  end

  ENV["LC_ALL"] = "en_US.UTF-8"

  # Setup the git user credentials
  config.vm.provision :shell, privileged: false, :inline => "git config --global user.name \"" + vagrant_config['git_config_user_name'] + "\""
  config.vm.provision :shell, privileged: false, :inline => "git config --global user.email \"" + vagrant_config['git_config_user_email'] + "\""

  # Copy all files specified in the config to the guest
  copy_files.each do |file|
    config.vm.provision :shell, :inline => "echo Copying file " + file['file'] + " to " + file['copy_to']
    config.vm.provision :file, source: file['file'], destination: "~/file"
    config.vm.provision :shell, inline: "sudo mv /home/vagrant/file " + file['copy_to']
  end

  # Execute commands in box
  commands.each do |command|
    config.vm.provision :shell, privileged: false, :inline => "echo Executing command " + command
    config.vm.provision :shell, privileged: false, :inline => command
  end

  Vagrant.configure("2") do |config|
    # forward ssh keys to box
    config.ssh.private_key_path = "~/.ssh/id_rsa"
    config.ssh.forward_agent = true
  end

  # If the project directory not exists on the host machine, create it
  directory_name = "./project/"
  Dir.mkdir(directory_name) unless File.exists?(directory_name)

  database_scripts.each do |file|
    config.vm.provision :shell, :inline => "echo Executing database script " + file
    config.vm.provision :file, source: file, destination: "~/database_import.sql"
    config.vm.provision :shell, inline: "mysql < /home/vagrant/database_import.sql"
  end

  # Add known hosts
  known_hosts.each do |known_host|
    config.vm.provision :shell, privileged: false, :inline => "ssh-keyscan " + known_host + ">> ~/.ssh/known_hosts"
  end

  # Restart the defined services
  restart_services.each do |service_name|
    config.vm.provision :shell, privileged: true, :inline => "service " + service_name + " restart"
  end

  # Do for each project
  projects.each do |project|

    # File must be copied first to user directory because file provisioning does not support sudo
    config.vm.provision :shell, :inline => "echo configuring vhost file for " + project['domain']

    if vagrant_config['webserver'] == 'nginx'
        config.vm.provision :file, source: "./templates/domain.nginx.conf", destination: "~/domain.conf"
    elsif vagrant_config['webserver'] == 'apache'
        config.vm.provision :file, source: "./templates/domain.apache.conf", destination: "~/domain.conf"
    end

    # Replace project name with variabele project_name in the vhost file
    config.vm.provision :shell, inline: "sed -i -e 's/domain/" + project['domain'] + "/g' /home/vagrant/domain.conf"
    config.vm.provision :shell, inline: "sed -i -e 's/web_dir/" + project['web_dir'] + "/g' /home/vagrant/domain.conf"

    # Move vhost conf file to the correct directory and set selinux settings
    if vagrant_config['webserver'] == 'nginx'
        config.vm.provision :shell, inline: "sudo mv /home/vagrant/domain.conf /etc/nginx/conf.d/" + project['domain'] + ".conf"
        config.vm.provision :shell, inline: "sudo restorecon -v /etc/nginx/conf.d/" + project["domain"] + ".conf"
    elsif vagrant_config['webserver'] == 'apache'
        config.vm.provision :shell, inline: "sudo mv /home/vagrant/domain.conf /etc/httpd/conf.d/" + project['domain'] + ".conf"
        config.vm.provision :shell, inline: "sudo restorecon -v /etc/httpd/conf.d/" + project["domain"] + ".conf"
    end

    # Setup the project
    if Dir['./project/' + project['domain']].empty?
      config.vm.provision :shell, inline: <<-SHELL, privileged: false do |shell|
        echo "Setting up the project directory for domain $2"
        git clone $1 "/var/www/htdocs/$2/"
        SHELL
        shell.args = [project['git_repo'], project['domain']]
      end
    end

    if project['composer_install']
      config.vm.provision :shell, inline: <<-SHELL, privileged: false do |shell|
        cd "/var/www/htdocs/$1/$2"
        composer install
        SHELL
        shell.args = [project['domain'], project['composer_install_dir']]
      end
    end

    # Execute all the commands that belong to the project
    commands = project['commands']
    commands.each do |command|
      config.vm.provision :shell, inline: <<-SHELL, privileged: false do |shell|
          echo "Executing command $2 for project with domain $3 in directory /var/www/htdocs/$3/$1"
          cd "/var/www/htdocs/$3/$1"
          $2
        SHELL
        shell.args = [command['execute_dir'], command['command'], project['domain']]
      end
    end
  end

  # The synced folder causes a problem with selinux so for now selinux is disabled
  config.vm.provision :shell, privileged: true, :inline => "setenforce 0"
  if vagrant_config['webserver'] == 'nginx'
    config.vm.provision :shell, privileged: true, :inline => "service nginx restart"
  elsif vagrant_config['webserver'] == 'apache'
    config.vm.provision :shell, privileged: true, :inline => "service httpd restart"
  end

  # Configure database
  config.vm.provision :shell, :inline => "echo Grant all privileges to root user on all databases"
  config.vm.provision :shell, inline: "mysql -e \"GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'password' WITH GRANT OPTION;\""

  # Configure synced folders
  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.vm.synced_folder './project', '/var/www/htdocs/'
end
