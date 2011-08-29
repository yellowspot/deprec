#helpers
module Minus5

  #helper for defining common config tasks config_gen and config
  def self.define_config_tasks(that, key)
    that.desc <<-DESC
    Generate #{key.to_s} config from template. Note that this does not
    push the config to the server, it merely generates required
    configuration files. These should be kept under source control.            
    The can be pushed to the server with the :config task.
    DESC
    that.task :config_gen do
      SYSTEM_CONFIG_FILES[key].each do |file|
        deprec2.render_template(key, file)
      end
    end
    
    that.desc "Push #{key.to_s} config files to server"
    that.task :config, :roles => :app do
      deprec2.push_configs(key, SYSTEM_CONFIG_FILES[key])
    end
  end

end

#defaults
Capistrano::Configuration.instance(:must_exist).load do 
  set :rvm_bin_path, "/usr/local/rvm/bin"  
  default_run_options[:pty] = true
end

#recipes
require "#{File.dirname(__FILE__)}/recipes/erlang"
require "#{File.dirname(__FILE__)}/recipes/rabbitmq"
require "#{File.dirname(__FILE__)}/recipes/rvm"
require "#{File.dirname(__FILE__)}/recipes/freetds"
require "#{File.dirname(__FILE__)}/recipes/god"
require "#{File.dirname(__FILE__)}/recipes/zeromq"
require "#{File.dirname(__FILE__)}/recipes/timezone"
require "#{File.dirname(__FILE__)}/recipes/minus5"
