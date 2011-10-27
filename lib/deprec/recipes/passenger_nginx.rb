# Copyright 2006-2008 by Mike Bailey. All rights reserved.
Capistrano::Configuration.instance(:must_exist).load do 
  namespace :passenger_nginx do 
    
    set :passenger_version, '3.0.9'

    task :install do
      passenger
      config
    end
    
    task :passenger do
      apt.get %w(libcurl4-openssl-dev)
      # naredne dvije linije vjerojatno nisu potrebne - probaj bez toga u slijedecoj iteraciji pa ih onda makni
      # run "#{sudo} #{rvm_bin_path}/rvm 1.9.2 --passenger"
      # run "#{sudo} #{rvm_bin_path}/rvm 1.9.2"
      run "#{sudo} #{rvm_bin_path}/gem install passenger --version=#{passenger_version} --no-rdoc --no-ri"
      run "rvmsudo passenger-install-nginx-module --auto --auto-download --prefix=/opt/nginx --extra-configure-flags='--with-http_gzip_static_module'"
      config
    end

    task :config do
      run "#{sudo} mkdir -p /etc/nginx"
      run "#{sudo} mkdir -p /etc/nginx/conf.d"
      run "#{sudo} cp /opt/nginx/conf/* /etc/nginx"
      run "#{sudo} mkdir -p /var/log/nginx"
      run "#{sudo} chown nobody /var/log/nginx"
      config_gen
      config_push
    end

    SYSTEM_CONFIG_FILES[:passenger_nginx] = [
                                             {:template => 'nginx.conf.erb',
                                               :path => '/etc/nginx/nginx.conf',
                                               :mode => 0755,
                                               :owner => 'root:root'},
                                             {:template => 'init.d.erb',
                                               :path => '/etc/init.d/nginx',
                                               :mode => 0755,
                                               :owner => 'root:root'},
                                             {:template => 'logrotate.conf.erb',
                                               :path => '/etc/logrotate.d/god.conf',
                                               :mode => 0644,
                                               :owner => 'root:root'}                                       
                                            ]

    desc "Generate Nginx configs from template."
    task :config_gen do
      SYSTEM_CONFIG_FILES[:passenger_nginx].each do |file|
        deprec2.render_template(:passenger_nginx, file)
      end
    end

    desc "Push Nginx configs to server"
    task :config_push, :roles => :app do
      deprec2.push_configs(:passenger_nginx, SYSTEM_CONFIG_FILES[:passenger_nginx])
    end

  end
end



