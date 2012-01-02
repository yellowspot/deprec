Capistrano::Configuration.instance(:must_exist).load do 
  namespace :passenger_nginx do 
    
    set :passenger_version       , '3.0.11'
    set :passenger_root          , "#{rbenv_root}/versions/1.9.2-p290/lib/ruby/gems/1.9.1/gems/passenger-3.0.11"
    set :passenger_ruby          , "#{rbenv_root}/versions/1.9.2-p290/bin/ruby"
    set :passenger_nginx_install , "#{rbenv_root}/versions/1.9.2-p290/bin/passenger-install-nginx-module"

    set :ssl_on, false
    set :passenger_max_pool_size, 4

    task :install do
      unless capture("if [ -e /opt/nginx ]; then echo 'installed' ; fi").empty?
        logger.info "nginx is already installed"
        next
      end
      passenger
      config
      start
    end
 
    task :passenger do
      apt.get %w(libcurl4-openssl-dev libpcre3 libpcre3-dev)
      run "gem install passenger --version=#{passenger_version} --no-rdoc --no-ri"
      sudo "#{passenger_nginx_install} --auto --auto-download --prefix=/opt/nginx --extra-configure-flags='--with-http_gzip_static_module --with-http_ssl_module'"
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

    ["start", "stop", "restart"].each do |t|
      task t.to_sym do 
        sudo "service nginx #{t}"
      end
    end

    #FIXME - ovdje postoji i init.d i upstart skripta, izbaci init.d
    SYSTEM_CONFIG_FILES[:passenger_nginx] = [
                                             {:template => 'upstart.conf',
                                               :path => '/etc/init/nginx.conf',
                                               :mode => 0644,
                                               :owner => 'root:root'},
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

    Helpers.define_config_tasks self, :passenger_nginx

    desc "Upload ssl certificate files to server, certificates should be stored in ./config/certs prefixed by domain name: www.examle.com.crt and www.example.com.key"
    task :upload_ssl_certs do      
      sudo "mkdir -p /etc/nginx/certs"
      upload("./config/certs/#{domain}.crt", "/tmp/#{domain}.crt", :via => :scp)
      upload("./config/certs/#{domain}.key", "/tmp/#{domain}.key", :via => :scp)
      sudo "mv /tmp/#{domain}.* /etc/nginx/certs/"
      sudo "chmod 0600 /etc/nginx/certs/#{domain}.*"
    end

  end
end



