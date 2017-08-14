#!/usr/bin/env ruby

class File
  # Copy a file from the host machine to the guest machine
  def self.copy_to(config, from, to)
    config.vm.provision :shell, :inline => "echo Copying file " + from + " to " + to
    config.vm.provision :file, source: from, destination: "~/file"
    config.vm.provision :shell, inline: "sudo mv /home/vagrant/file " + to
  end
end
