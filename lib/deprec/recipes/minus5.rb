Capistrano::Configuration.instance(:must_exist).load do

  #monit defaults
  set :monit_check_interval, 10
  set :monit_mailserver, 'mail.iskon.hr'
  set :monit_mail_from, 'monit@supersport.hr'
  set :monit_alert_recipients, %w(ianic@minus5.hr)
  set :monit_timeout_recipients, %w()
  #enable web server for all hosts
  set :monit_webserver_allowed_hosts_and_networks, %w()
  set :monit_webserver_address, nil

  namespace :minus5 do
    namespace :server do

      desc "instalacija uobicajenih lib-ova za aplication server: rvm (ruby 1.8.7 1.9.2), freetds, zeromq, monit"
      task :setup do
        deprec::rvm::install
        deprec::rvm::install_rubies
        deprec::freetds::install
        apt.install({:base => %w(subversion zlib1g-dev uuid-dev)}, :stable)
        zeromq
        gems
        #deprec::monit::install
      end

      task :gems do
        run "#{sudo} #{rvm_bin_path}/rvm gem install --no-rdoc --no-ri bundler god"
        run "#{sudo} #{rvm_bin_path}/rvm wrapper ruby-1.9.2 bootup god"
      end

      desc "zeromq instalacija, s podrskom za multicasting"
      task :zeromq do
        next unless capture("if[ -e /usr/local/lib/libzmq.so ]; then echo 'installed' ; fi").empty?
        zeromq_src = {:url => "http://download.zeromq.org/zeromq-2.1.7.tar.gz",
          :configure => "./configure --with-pgm"}
        deprec2.download_src(zeromq_src, src_dir)
        deprec2.install_from_src(zeromq_src, src_dir)  
      end

      desc "yui-compressor, izdvojen iz setup jer povuce cijelu javu, pa ako nije nuzno da ga ne potezem"
      task :yui_compressor do
        apt.install({:base => %w(yui-compressor)}, :stable)
      end

    end
  end

  after "deploy:setup", "fix_dir_permissions"
  desc "change group to deploy_group on dirs created during deploy:setup"
  task :fix_dir_permissions do
    dirs = [deploy_to, releases_path, shared_path]
    dirs += shared_children.map { |d| File.join(shared_path, d) }
    group = deploy_group || "admin"
    run "#{try_sudo} chgrp #{group} #{dirs.join(' ')}"
  end

  #shared files handling (next three tasks)
  #shared files are symlinked from shared to the same location in release_path for each deploy
  #initiali empty files are created during deploy:setup
  #if file exists in relase_path it is deleted and then replaced with symlink to shared
  before "deploy:setup", "add_shard_files_to_shared_children"
  task :add_shard_files_to_shared_children do
    next unless exists?(:shared_files)
    shared_files.each do |file|
      shared_children << File.dirname(file)
    end
  end

  after "deploy:setup", "create_shared_files"
  task :create_shared_files do
    next unless exists?(:shared_files)
    shared_files.each  do |file|
      run "touch #{shared_path}/#{file}"
    end
  end

  after "deploy:update_code", "symlink_shared_files"
  task :symlink_shared_files do
    next unless exists?(:shared_files)
    shared_files.each do |file|
      run "rm -f #{release_path}/#{file}"
      run "ln -nfs #{shared_path}/#{file} #{release_path}/#{file}"
    end
  end

end

