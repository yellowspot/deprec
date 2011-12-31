#defaults
Capistrano::Configuration.instance(:must_exist).load do 
  #bundler
  require "bundler/capistrano"
  set :bundle_cmd, Proc.new{ "/usr/local/rvm/gems/#{rvm_ruby_string}/bin/bundle" }

  unless exists?(:no_rvm)
    $:.unshift(File.expand_path('./lib', ENV['rvm_path']))
    require "rvm/capistrano"
    df = default_shell
    set :shell_with_rvm, Proc.new { df }
  end

  default_run_options[:pty] = true
  
  #paths
  set :rvm_bin_path, "/usr/local/rvm/bin"    
  set :god_bin, '/usr/local/rvm/wrappers/ruby-1.9.2-p290/god'
  set :gem_bin, "#{rvm_bin_path}/gem"
  
  #deployment options - application and svn_root should be set in deploy.rb
  set :deploy_group,  "deploy"
  set :deploy_to,     Proc.new { "/var/apps/#{application}" }
  set :svn_arguments, "--username deploy --password deploy --no-auth-cache"
  set :repository,    Proc.new { "#{svn_arguments} #{svn_root}" }

  #options for god config
  set :runner,          "runner"
  set :log_file_path,   Proc.new { "/var/log/god/#{application}.log" }
  set :start_command,   Proc.new { "/usr/local/rvm/bin/#{rvm_ruby_string} bin/#{application}.rb" }
  set :notify_contacts, ['ianic', 'campfire'] 
  
  set :god_log_file_inactivity_minutes, 10
  set :god_max_memory_usage_megabytes, 200
end
