module Helpers

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
    that.task :config_push, :roles => :app do
      deprec2.push_configs(key, SYSTEM_CONFIG_FILES[key])
    end

    that.task :config do
      config_gen
      config_push
    end
  end
  
end
