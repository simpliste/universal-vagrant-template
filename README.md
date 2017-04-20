Development box template

### Pre-reqs

* Vagrant (tested with 1.8.6 and & 1.9.1)
* Virtual box (tested with 5.1.8 )
* Public and private key on your host machine which are added to your bitbucket account. (these keys are automatically
  added to the vagrant box)
* When 'vagrant up' is failing, it is possible that you need the vb box guest plugin
* See: http://stackoverflow.com/questions/22717428/vagrant-error-failed-to-mount-folders-in-linux-guest

### Versions

See atlas.hashicorp for more information about the box. 
https://atlas.hashicorp.com/ajnijland/boxes
For the version and box that you are using look in config.yml to the variables:
vagrant_box & vagrant_box_version

### Instructions

* `vagrant up`
* add "dev.projectname.com" to your host file with the ip address you entered in the config.yml file (private_box_ip)
* go to dev.projectname.com and see an working version of the api
* The default user name of the mysql database is "root" with password "password"
* for more documentation, see the documentation of the box on atlas or checkout the repository with the ansible source environment

### Documentation

The project will be located in /var/www/htdocs/dev.projectname.com and is mounted in the vagrant folder in /project.
You must always use git from within your development box. The folder on your host machine is actually mounted / shared
with the host.

During provisioning a database is automatically created in the vagrant box. After provisioning you can go to "dev.projectname.com" and you are up and running!
