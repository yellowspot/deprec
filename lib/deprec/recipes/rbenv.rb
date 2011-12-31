require 'helpers'
require 'git'

Capistrano::Configuration.instance(:must_exist).load do 
  namespace :rbenv do

    SYSTEM_CONFIG_FILES[:rbenv] = [
                                   {:template => 'rbenv.sh.erb',
                                     :path => '/etc/profile.d/rbenv.sh',
                                     :mode => 0755,
                                     :owner => 'root:root'}
                                  ]

    Helpers.define_config_tasks self, :rbenv

    desc "Install rbenv"
    task :install do
      unless capture("if [ -e /usr/local/rbenv/ ]; then echo 'installed' ; fi").empty?
        logger.info "rbenv is already installed"
        next
      end
      install_deps
      install_rbenv
      config_gen
      config_push
      #run "source /etc/profile.d/rbenv.sh"      
      install_build
    end

    task :install_rbenv do
      run "#{sudo} rm -rf /usr/local/rbenv"
      run "#{sudo} git clone git://github.com/sstephenson/rbenv.git /usr/local/rbenv"
    end
    
    task :install_build do
      run "#{sudo} rm -rf /tmp/ruby-build"
      run "#{sudo} git clone git://github.com/sstephenson/ruby-build.git /tmp/ruby-build"
      run "#{sudo} sh -c 'cd /tmp/ruby-build; ./install.sh'"
    end
    
    task :install_deps do
      deprec::git::install
      apt.get %w(curl build-essential bison openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev)
    end

    ["ree-1.8.7-2011.03", "1.9.2-p290", "1.9.3-rc1"].each do |v|
      desc "Install ruby #{v}"      
      task "ruby_#{v.gsub(".","_").gsub("-", "_")}".to_sym do
        if capture("#{rbenv_bin} versions").include?(v)
          logger.info "Ruby #{v} is already installed"
          next
        end     
        run "sudo #{rbenv_bin} install #{v}"
        run "sudo #{rbenv_bin} global #{v}"
        run "sudo #{rbenv_bin} rehash"
      end
    end

    task :set_environment do
      set :rbenv_root, "/usr/local/rbenv"
      set :rbenv_bin, "RBENV_ROOT=#{rbenv_root} /usr/local/rbenv/bin/rbenv"
      set :rbenv_sudo_path, "PATH=#{rbenv_root}/shims:#{rbenv_root}/bin:$PATH RBENV_ROOT=#{rbenv_root}"

      set :default_environment, {
        'PATH' => "#{rbenv_root}/shims:#{rbenv_root}/bin:$PATH",
        'RBENV_ROOT' => rbenv_root
      }
    end

  end
end

module CapRbenv
  
  def sudo(command)
    run "sudo sh -c '#{rbenv_sudo_path} #{command}'"
  end

end

Capistrano.plugin :cap_rbenv, CapRbenv
