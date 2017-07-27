# Development box template

## Pre-reqs

* Vagrant (tested with 1.9.1)
* Virtual box (tested with 5.1.22)
* Public and private key on your host machine which are added to your bitbucket account. (these keys are automatically
  added to the vagrant box)
* When 'vagrant up' is failing, it is possible that you need the vb box guest plugin
* See: http://stackoverflow.com/questions/22717428/vagrant-error-failed-to-mount-folders-in-linux-guest

## Versions

See atlas.hashicorp for more information about the box. 
https://atlas.hashicorp.com/ajnijland/boxes
For the version and box that you are using look in config.yml to the variables:
vagrant_box & vagrant_box_version

## Instructions

* fill in all the variables in the config file
* `vagrant up`
* configure your host file (on host machine) so that it matches with the values from config.yml file (private_box_ip and domain)
* go to the domain you filled in and see a working version of your project
* The default user name of the mysql database is "root" with password "password"
* for more documentation, see the documentation of the box on atlas or checkout the repository with the ansible source environment

## Documentation

The project will be located in /var/www/htdocs/{domain} <- from your config file and is mounted in the vagrant folder in /project.

## License

MIT / BSD

## Author Information

This vagrant template was created in 2017 by Ard-Jan Nijland.

