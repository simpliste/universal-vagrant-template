#!/usr/bin/env ruby

class Project
  def self.setup_nginx_vhost(config, domain, web_dir)
    config.vm.provision :file, source: "./templates/domain.nginx.conf", destination: "~/domain.conf"

    File.copy_to(config, './templates/domain.nginx.conf', '/etc/nginx/conf.d/' + domain + '.conf')

    # Replace project name with variabele project_name in the vhost file
    File.replace(config, 'domain', domain, '/etc/nginx/conf.d/' + domain + '.conf')
    File.replace(config, 'web_dir', web_dir, '/etc/nginx/conf.d/' + domain + '.conf')
    config.vm.provision :shell, inline: "sudo restorecon -v /etc/nginx/conf.d/" + domain + ".conf"
  end


  def self.setup_apache_vhost(config, domain, web_dir)
    File.copy_to(config, './templates/domain.apache.conf', '/etc/httpd/conf.d/' + domain + '.conf')
    File.copy_to(config, './templates/httpd.conf', '/etc/httpd/conf/httpd.conf')

    # Replace project name with variabele project_name in the vhost file
    File.replace(config, 'domain', domain, '/etc/httpd/conf.d/' + domain + '.conf')
    File.replace(config, 'web_dir', web_dir, '/etc/httpd/conf.d/' + domain + '.conf')

    config.vm.provision :shell, inline: "sudo restorecon -v /etc/httpd/conf.d/" + domain + ".conf"
  end


  def self.setup_vhost(config, domain, web_dir, webserver)
    config.vm.provision :shell, :inline => "echo configuring vhost file for " + domain

    if (webserver == 'apache')
      self.setup_apache_vhost(config, domain, web_dir)
    elsif (webserver == 'nginx')
      self.setup_nginx_vhost(config, domain, web_dir)
    end

  end


  def self.clone_repo(config, repo, folder_name)
    if Dir['./project/' + folder_name].empty?
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
    commands.each do |command|
      config.vm.provision :shell, inline: <<-SHELL, privileged: false do |shell|
          echo "Executing command $2 for project with domain $3 in directory /var/www/htdocs/$3/$1"
          cd "/var/www/htdocs/$3/$1"
          $2
        SHELL
        shell.args = [command['execute_dir'], command['command'], domain]
      end
    end
  end


  # Do everything that is needed to correctly setup a new project in the box
  def self.setup(config, project, webserver)
    self.setup_vhost(config, project['domain'], project['web_dir'], webserver)
    self.clone_repo(config, project['git_repo'], project['domain'])

    if project['composer_install']
      self.composer_install(config, project['domain'], project['composer_install_dir'])
    end

    self.execute_command(config, project['commands'], project['domain'])
  end
end
