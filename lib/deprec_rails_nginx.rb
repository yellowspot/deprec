unless Capistrano::Configuration.respond_to?(:instance)
  abort "deprec2 requires Capistrano 2"
end

require "#{File.dirname(__FILE__)}/deprec/capistrano_extensions"
require "#{File.dirname(__FILE__)}/vmbuilder_plugins/all"

#load minimal required recipes
%w(deprec ssh users defaults config log mysql).
  each do |recipe|
  require recipes_dir = "#{File.dirname(__FILE__)}/deprec/recipes/#{recipe}.rb"
end

Capistrano::Configuration.instance(:must_exist).load do 
  
  #defaults customization
  set :rvm_ruby_string , 'ruby-1.9.2-p290'
  set :deploy_to       , Proc.new { "/var/www/apps/#{application}" }
  set :log_file_path   , Proc.new { "#{shared_path}/log/#{stage}.log" }
  set :server_type     , "nginx"

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

  desc "create user remotely add it to admin and deploy group"
  task :useradd do 
    set(:users_target_user) { 
      Capistrano::CLI.ui.ask "Enter userid" do |q| 
        q.default = current_user; 
      end 
    }
    deprec2.groupadd :deploy
    deprec2.useradd users_target_user
    deprec2.add_user_to_group users_target_user, :deploy
    deprec2.add_user_to_group users_target_user, :admin
    top.deprec.users.passwd
  end

end