#!/usr/bin/env ruby

class Project
  def self.setup_nginx_vhost(config, domain, web_dir)
    config.vm.provision :file, source: "./templates/domain.nginx.conf", destination: "~/domain.conf"

    File.copy_to(config, './templates/domain.nginx.conf', "/etc/nginx/conf.d/#{domain}.conf")

    # Replace project name with variabele project_name in the vhost file
    File.replace(config, 'domain', domain, "/etc/nginx/conf.d/#{domain}.conf")
    File.replace(config, 'web_dir', web_dir, "/etc/nginx/conf.d/#{domain}.conf")
    config.vm.provision :shell, inline: "sudo restorecon -v /etc/nginx/conf.d/#{domain}.conf"
    config.vm.provision :shell, inline: "touch /etc/nginx/fastcgi_params_#{domain}", privileged: true
  end


  def self.setup_apache_vhost(config, domain, web_dir)
    File.copy_to(config, './templates/domain.apache.conf', "/etc/httpd/conf.d/#{domain}.conf")
    # Set the vagrant user and group for apache instead of copying the whole file
    File.replace(config, 'User apache', 'User vagrant', '/etc/httpd/conf/httpd.conf');
    File.replace(config, 'Group apache', 'User vagrant', '/etc/httpd/conf/httpd.conf');
    File.replace(config, '#ServerName www.example.com:80', 'ServerName localhost', '/etc/httpd/conf/httpd.conf');

    # Replace project name with variabele project_name in the vhost file
    File.replace(config, 'domain', domain, "/etc/httpd/conf.d/#{domain}.conf")
    File.replace(config, 'web_dir', web_dir, "/etc/httpd/conf.d/#{domain}.conf")

    config.vm.provision :shell, inline: "sudo restorecon -v /etc/httpd/conf.d/#{domain}.conf"
  end


  def self.setup_vhost(config, domain, web_dir, webserver)
    config.vm.provision :shell, :inline => "echo configuring vhost file for #{domain}"

    if (webserver == 'apache')
      self.setup_apache_vhost(config, domain, web_dir)
    elsif (webserver == 'nginx')
      self.setup_nginx_vhost(config, domain, web_dir)
    end

  end


  def self.clone_repo(config, repo, folder_name)
    if Dir["./project/#{folder_name}"].empty?
      config.vm.provision :shell, inline: <<-SHELL, privileged: false do |shell|
        echo "Setting up the project directory for domain $2"
        git clone $1 "/var/www/htdocs/$2/"
        SHELL
        shell.args = [repo, folder_name]
      end
    end
  end


  def self.composer_install(config, project_dir, composer_install_dir)
    config.vm.provision :shell, inline: <<-SHELL, privileged: false do |shell|
      cd "/var/www/htdocs/$1/$2"
      composer install
      SHELL
      shell.args = [project_dir, composer_install_dir]
    end
  end


  def self.execute_command(config, commands, domain)
    (commands || []).each do |command|
      config.vm.provision :shell, inline: <<-SHELL, privileged: false do |shell|
        echo "Executing command $2 for project with domain $3 in directory /var/www/htdocs/$3/$1"
        cd "/var/www/htdocs/$3/$1"
        $2
        SHELL
        shell.args = [command['execute_dir'], command['command'], domain]
      end
    end
  end


  def self.create_vhost_environment_variables(config, variables, domain, webserver)
    config.vm.provision :shell, inline: 'echo "Adding variables to the vhost configuration"'
    (variables || []).each do |variable, value|
      config.vm.provision :shell, inline: <<-SHELL, privileged: true do |shell|
        if [ "$4" == "apache" ]; then
          sudo sed -i "s|</VirtualHost>|SetEnv $1 $2\\n</VirtualHost>|" /etc/httpd/conf.d/$3.conf
        elif [ "$4" == "nginx" ]; then
          sudo bash -c \"echo 'fastcgi_param $1 $2;' >> /etc/nginx/fastcgi_params_$3\"
        fi
        SHELL
        shell.args = [variable, value, domain, webserver]
      end
    end
  end


  def self.create_project_environment_variables(config, variables, domain)
    config.vm.provision :shell, inline: 'echo "First removing .env file if exists and then creating new .env file for the project"'

    config.vm.provision :shell, inline: "rm -f /var/www/htdocs/#{domain}/.env"
    (variables || []).each do |variable, value|
      if value.nil?
        config.vm.provision :shell, inline: "echo #{variable} >> /var/www/htdocs/#{domain}/.env"
      else
        config.vm.provision :shell, inline: "echo #{variable}=#{value} >> /var/www/htdocs/#{domain}/.env"
      end
    end
  end


  # Do everything that is needed to correctly setup a new project in the box
  def self.setup(config, project, webserver)
    self.setup_vhost(config, project['domain'], project['web_dir'], webserver)
    self.clone_repo(config, project['git_repo'], project['domain'])

    self.create_vhost_environment_variables(config, project['environment_variables_web_server'], project['domain'], webserver)
    self.create_project_environment_variables(config, project['environment_variables_file'], project['domain'])

    if project['composer_install']
      self.composer_install(config, project['domain'], project['composer_install_dir'])
    end

    self.execute_command(config, project['commands'], project['domain'])
  end
end
