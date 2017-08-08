# Universal vagrant template

## Concept
The idea is to provide a vagrant template which offers the ability to fully setup a new project(or projects) where no 
manual configuration has to be done afterwards. Check out the config.yaml to get an idea of what is possible.

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

## How to use this universal vagrant template
* Checkout this project, i suggest checking out the latest version. <br>
* `git clone --depth=1 git@github.com:Ard-Jan/universal-vagrant-template-box-example.git`
* Go to the directory "box" and coppy config.yaml.dist to config.yaml and edit the configuration file to your needs. The default values in the config.yml.dist file can also be used as an example to see how it works.
* Now you are ready and you can start the box by running `vagrant up`

You can use all kind of vagrant boxes that are provided on[Vagrant Cloud](https://app.vagrantup.com/boxes/search), the 
only thing that this template expects is that either nginx or apache is available in the box because it tries to set the vhost.

## Backup your implementation in Git
All the files in the directory box/* are excluded in the .gitignore from this template, so you can push your specific implementation in your own git repository for example.
* Go to the directory 'box'
* `git init`
* `git remote add origin {your remote url}`
* Now you are able to get along with updates of the universal-vagrant-template by just checking out the new version in the box.

## License

MIT / BSD

## Author Information

This vagrant template was created in 2017 by Ard-Jan Nijland.

