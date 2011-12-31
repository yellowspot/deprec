#FIXME - rvm dependent
Capistrano::Configuration.instance(:must_exist).load do 
  namespace :god do 

    SYSTEM_CONFIG_FILES[:god] = [               
               {:template => 'upstart.conf',
                 :path => '/etc/init/god.conf',
                 :mode => 0644,
                 :owner => 'root:root'},
               {:template => 'god.god.erb',
                 :path => '/etc/god.god',
                 :mode => 0644,
                 :owner => 'root:root'},
               {:template => 'logrotate.conf.erb',
                 :path => '/etc/logrotate.d/god.conf',
                 :mode => 0644,
                 :owner => 'root:root'}
              ]

    Minus5.define_config_tasks self, :god

    desc "god install"
    task :install do
      run "#{sudo} #{rvm_bin_path}/rvm gem install --no-rdoc --no-ri god json"
      run "#{sudo} #{rvm_bin_path}/rvm wrapper ruby-1.9.2 bootup god"
      run "#{sudo} #{rvm_bin_path}/rvm wrapper ree-1.8.7-2011.03 bootup god"
      run "#{sudo} mkdir -p /etc/god.d"
      run "#{sudo} mkdir -p /var/run/god"
      run "#{sudo} mkdir -p /var/log/god"
      run "#{sudo} chown runner /var/log/god"
      run "#{sudo} chgrp runner /var/log/god"
      config_gen
      config
      start
    end

    [:start, :stop, :restart, :status].each do |task|
      desc "#{task.to_s} god service"
      task task do
        run "#{sudo} initctl #{task.to_s} god"
      end
    end

  end
end
