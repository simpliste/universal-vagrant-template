#!/usr/bin/env ruby

class File
  # Copy a file from the host machine to the guest machine
  def self.copy_to(config, from, to)
    config.vm.provision :shell, :inline => "echo Copying file " + from + " to " + to
    config.vm.provision :file, source: from, destination: "~/file"
    config.vm.provision :shell, inline: "sudo mv /home/vagrant/file " + to
  end

  # Replace a specific value in a file
  def self.replace(config, search, replace, file)
    config.vm.provision :shell, inline: "sed -i -e 's/" + search + "/" + replace + "/g' " + file
  end
end
