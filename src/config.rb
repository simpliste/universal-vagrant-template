#!/usr/bin/env ruby

class Config

  def self.build(base_config, box_config, user_config)
    if not File.exists?(user_config)
      puts "The file #{user_config} does not exist, it is needed for provisioning. Check the readme file for more information about the setup of this project.".red
    end

    if not File.exists?(box_config)
      puts "The file #{box_config} does not exist, it is needed for provisioning. Check the readme file for more information about the setup of this project.".red
    end

    if not File.exists?(user_config) or not File.exists?(box_config)
      exit
    end

    base_config = YAML.load_file(base_config)
    box_config = YAML.load_file(box_config)
    user_config = YAML.load_file(user_config)

    base_config = base_config['config'].deep_merge(box_config['config']).deep_merge(user_config['config'])

    return base_config
  end
end
