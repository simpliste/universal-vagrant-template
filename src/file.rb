#!/usr/bin/env ruby

class File
  # Copy a file from the host machine to the guest machine
  def self.copy_to(config, from, to)
    config.vm.provision :shell, :inline => "echo Copying file #{from} to #{to}"
    config.vm.provision :file, source: from, destination: "/home/vagrant/file"
    config.vm.provision :shell, inline: "sudo mv /home/vagrant/file #{to}"
  end

  # Replace a specific value in a file
  def self.replace(config, search, replace, file)
    config.vm.provision :shell, inline: "sed -i -e 's/#{search}/#{replace}/g' #{file}"
  end

  # Remove a file or folder from the box
  def self.remove(config, path)
    config.vm.provision :shell, privileged: true, :inline => "echo Removing data #{path} from box before copying syncing"
    config.vm.provision :shell, privileged: true, :inline => "rm -rf #{path}"
  end
end
