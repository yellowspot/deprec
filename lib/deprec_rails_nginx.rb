unless Capistrano::Configuration.respond_to?(:instance)
  abort "deprec2 requires Capistrano 2"
end

require "#{File.dirname(__FILE__)}/deprec/capistrano_extensions"
require "#{File.dirname(__FILE__)}/vmbuilder_plugins/all"

#add recipes dir to load path, so one could require single recipe 
$: << File.expand_path(File.join(File.dirname(__FILE__), "deprec", "recipes"))

%w(canonical deprec ssh users config log mysql rbenv passenger_nginx).
  each do |recipe|
  require "#{File.dirname(__FILE__)}/deprec/recipes/#{recipe}.rb"
end



Capistrano::Configuration.instance(:must_exist).load do 
  
  #deployment options - application and svn_root should be set in deploy.rb
  set :user          , "deploy"
  set :user_passed   , "ZeleniTrg3/1"
  set :deploy_group  , "deploy"
  set :deploy_to     , Proc.new { "/var/apps/#{application}" }
  set :deploy_via    , :remote_cache
  set :svn_arguments , "--username deploy --password deploy --no-auth-cache"
  set :repository    , Proc.new { "#{svn_arguments} #{svn_root}" }
  set :log_file_path , Proc.new { "#{shared_path}/log/#{stage}.log" }
  set :server_type   , "nginx"
  set :bundle_cmd    , Proc.new{ "/usr/local/rbenv/versions/1.9.2-p290/bin/bundle" }

  namespace :deploy do
    task :start do ; end
    task :stop  do ; end
    task :restart, :roles => :app, :except => { :no_release => true } do
      run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
    end
  end

  desc "change group to deploy_group (default is deploy) on dirs created during deploy:setup"
  task :fix_dir_permissions do
    dirs = [deploy_to, releases_path, shared_path]
    dirs += shared_children.map { |d| File.join(shared_path, d) }
    group = deploy_group || "admin"
    run "#{try_sudo} chgrp #{group} #{dirs.join(' ')}"
  end
  after "deploy:setup", "fix_dir_permissions"


  task :add_public_key_to_deploy_user do
    upload "#{ENV['HOME']}/.ssh/id_rsa.pub", "/tmp/id_rsa.pub", :via => :scp
    run "mkdir -p /home/#{user}/.ssh"
    run "cat /tmp/id_rsa.pub >> /home/#{user}/.ssh/authorized_keys"
    run "rm /tmp/id_rsa.pub"
    run "chmod 600 /home/#{user}/.ssh/authorized_keys"
    run "chmod 700 /home/#{user}/.ssh"    
  end

  desc "create user remotely add it to admin and deploy group"
  task :useradd do 
    set(:users_target_user) { 
      Capistrano::CLI.ui.ask "Enter userid" do |q| 
        q.default = current_user; 
      end 
    }
    deprec2.groupadd deploy_group
    deprec2.useradd users_target_user
    deprec2.add_user_to_group users_target_user, deploy_group
    deprec2.add_user_to_group users_target_user, :admin
    top.deprec.users.passwd
  end

  after 'deploy:update_code', 'symlink_configs'
  task :symlink_configs do
    project_config_files.each do |config|
      if config.has_key?(:release_path)        
        run "rm -f #{config[:release_path]}"
        run "ln -s #{config[:path]} #{config[:release_path]}"
      end
    end
  end

  ###############
  # dorada da ne radi assets precompile na serveru, nego lokalno pa ih upload-a
  before "deploy:update_code", "assets_precompile"
  after  "deploy:update_code", "assets_upload"

  task "assets_precompile" do
    #system("rm ./public/assets/*")
    system("bundle exec rake assets:precompile") 
  end

  task "assets_upload" do
    upload("./public/assets", "#{shared_path}", :via=> :scp, :recursive => true)
  end

  namespace :deploy do
    namespace :assets do
      task :precompile do
        # do not precompile assets on the server
      end
    end
  end
  ###############


end
