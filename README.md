Development box template

### Pre-reqs

* Vagrant (tested with 1.8.6 and & 1.9.1)
* Virtual box (tested with 5.1.8 )
* Public and private key on your host machine which are added to your bitbucket account. (these keys are automatically
  added to the vagrant box)
* When 'vagrant up' is failing, it is possible that you need the vb box guest plugin
* See: http://stackoverflow.com/questions/22717428/vagrant-error-failed-to-mount-folders-in-linux-guest

### Versions

* CentOS release 6.8 (Final)
* Nginx 1.10.2
* PHP 5.6.29
* MySQL 5.6.33

### Instructions

* `vagrant up`
* add "dev.projectname.com" to your host file with ip 192.168.56.75
* go to dev.projectname.com and see an working version of the api
* The default user name of the mysql database is "root" with password "password"
* for more documentation, see the documentation files and the project repository

### Documentation

The project will be located in /var/www/htdocs/dev.projectname.com and is mounted in the vagrant folder in /project.
You must always use git from within your development box. The folder on your host machine is actually mounted / shared
with the host.

During provisioning a database is automatically created in the vagrant box. After provisioning you can go to "dev.projectname.com" and you are up and running!
