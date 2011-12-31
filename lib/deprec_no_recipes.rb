unless Capistrano::Configuration.respond_to?(:instance)
  abort "deprec2 requires Capistrano 2"
end

require "#{File.dirname(__FILE__)}/deprec/capistrano_extensions"
require "#{File.dirname(__FILE__)}/vmbuilder_plugins/all"

require "#{File.dirname(__FILE__)}/deprec/recipes/canonical"
require "#{File.dirname(__FILE__)}/deprec/recipes/deprec"
#require "#{File.dirname(__FILE__)}/deprec/recipes/deprecated"

#add recipes dir to load path, so one could require single recipe 
$: << File.expand_path(File.join(File.dirname(__FILE__), "deprec", "recipes"))


Capistrano::Configuration.instance(:must_exist).load do 

  default_run_options[:pty] = true
  
  #deployment options - application and svn_root should be set in deploy.rb
  set :deploy_group,  "deploy"
  set :deploy_to,     Proc.new { "/var/apps/#{application}" }
  set :svn_arguments, "--username deploy --password deploy --no-auth-cache"
  set :repository,    Proc.new { "#{svn_arguments} #{svn_root}" }
end

