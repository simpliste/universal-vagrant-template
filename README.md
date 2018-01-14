# Universal vagrant template

## Concept
The idea is to provide a vagrant template which offers the ability to fully setup a new project(or projects) where no 
manual configuration has to be done afterwards. Check out the config.yaml to get an idea of what is possible.

## Pre-reqs

* [Vagrant](https://www.vagrantup.com/) (tested with 1.9.1)
* [Virtual](https://www.virtualbox.org/) box (tested with 5.1.22)
* Public and private key on your host machine which are added to your bitbucket account. (these keys are automatically
  added to the vagrant box)
* When 'vagrant up' is failing, it is possible that you need the vb box guest plugin
* See: http://stackoverflow.com/questions/22717428/vagrant-error-failed-to-mount-folders-in-linux-guest

## How to use?

* `git clone --depth=1 git@github.com:Ard-Jan/universal-vagrant-template.git`
* `cd universal-vagrant-template`
* `cp box/config.yaml.dist box/config.yaml`
* `cp box/config_user.yaml.dist box/config_user.yaml`
* `export VAGRANT_DEFAULT_PROVIDER="virtualbox"`
* `vagrant up`
*  add dev.project.com to the hosts file with the ip 192.168.56.190 (host file of host machine)

## How to customize
If you already followed the 'How to use?' step above first clean up by doing:
* `vagrant destroy && rm -rf .vagrant && rm -rf project`

Now you are ready te define your own box:
* Edit box/config.yaml the way you want it.
* Edit box/config_user.yaml with your information
* `vagrant up`
* add the domain to the hosts file with the ip you entered in the box/config.yml (host file of host machine)

## How to backup your box in VCS
The 'box' directory is not included in the repo of this template, so you can create your own repo for this implementation.
* `cd box`
* `git init`
* `git remote add origin {remote repository}`
* `git push -u origin master`
* Now you are still able to checkout new versions of the universal-vagrant-template 

## Information
The project will be located in /var/www/htdocs/{domain} <- from your config file and is mounted in the vagrant folder in /project.
You can use all kind of vagrant boxes that are provided on[Vagrant Cloud](https://app.vagrantup.com/boxes/search), the 
only thing that this template expects is that either nginx or apache is available in the box because it tries to set the vhost.

This template is tested with all boxes that you can find [here](https://app.vagrantup.com/ajnijland)

For the version and box that you are using look in config.yml to the variables:
vagrant_box & vagrant_box_version

## Example implementation
There is also an example implementation repository which you can checkout. If you already did some things in the box directory, first undo these changes.
* `cd box`
* `git init`
* `git remote add origin git@github.com:Ard-Jan/universal-vagrant-template-box-example.git`
* `git pull origin master`
* `cp config_user.yaml.dist config_user.yaml`
* `cd ../`
* `export VAGRANT_DEFAULT_PROVIDER = "virtualbox"`
* `vagrant up`
*  add dev.project.com to the hosts file with the ip 192.168.56.190 (host file of host machine)

## Backup your implementation in Git
All the files in the directory box/* are excluded in the .gitignore from this template, so you can push your specific implementation in your own git repository for example.
* Go to the directory 'box'
* `git init`
* `git remote add origin {your remote url}`
* Now you are able to get along with updates of the universal-vagrant-template by checking out the new version in the box.

## License

MIT / BSD

## Author Information

This vagrant template was created in 2017 by Ard-Jan Nijland.

