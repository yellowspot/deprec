# Copyright 2006-2008 by Mike Bailey. All rights reserved.
Capistrano::Configuration.instance(:must_exist).load do 
  namespace :deprec do
    namespace :mysql do
      
      set :mysql_admin_user, 'root'
      set(:mysql_admin_pass) { Capistrano::CLI.password_prompt "Enter database password for '#{mysql_admin_user}':"}
      
      # Installation
      
      desc "Install mysql"
      task :install, :roles => :db do
        apt.install( {:base => %w(mysql-server mysql-client libmysqlclient15-dev)}, :stable )
        config
      end
      
      # Configuration
      
      SYSTEM_CONFIG_FILES[:mysql] = [
        
        {:template => "my.cnf.erb",
         :path => '/etc/mysql/my.cnf',
         :mode => 0644,
         :owner => 'root:root'}
      ]
      
      desc "Generate configuration file(s) for mysql from template(s)"
      task :config_gen do
        SYSTEM_CONFIG_FILES[:mysql].each do |file|
          deprec2.render_template(:mysql, file)
        end
      end
      
      desc "Push mysql config files to server"
      task :config, :roles => :db do
        deprec2.push_configs(:mysql, SYSTEM_CONFIG_FILES[:mysql])
        reload
      end
      
      task :activate, :roles => :db do
        send(run_method, "update-rc.d mysql defaults")
      end  
      
      task :deactivate, :roles => :db do
        send(run_method, "update-rc.d -f mysql remove")
      end
      
      # Control
      
      desc "Start Mysql"
      task :start, :roles => :db do
        send(run_method, "service mysql start; exit 0")
      end
      
      desc "Stop Mysql"
      task :stop, :roles => :db do
        send(run_method, "service mysql stop")
      end
      
      desc "Restart Mysql"
      task :restart, :roles => :db do
        #send(run_method, "/etc/init.d/mysql restart")
        send(run_method, "service mysql restart")
      end
      
      desc "Reload Mysql"
      task :reload, :roles => :db do
        #send(run_method, "/etc/init.d/mysql reload")
        send(run_method, "service mysql reload")
      end
     

      # Extras (not sure if they still work) 
      # Create a database
      task :create_database, :roles => :db do
        cmd = "CREATE DATABASE IF NOT EXISTS #{db_name}"
        run "mysql -u #{mysql_admin_user} -p -e '#{cmd}'" do |channel, stream, data|
          if data =~ /^Enter password:/
             channel.send_data "#{mysql_admin_pass}\n"
           end
        end       
      end
      
      # "Grant user access to database" 
      task :grant_user_access_to_database, :roles => :db do        
        cmd = "GRANT ALL PRIVILEGES ON #{db_name}.* TO '#{db_user}'@localhost IDENTIFIED BY '#{db_password}';"
        run "mysql -u #{mysql_admin_user} -p #{db_name} -e \"#{cmd}\"" do |channel, stream, data|
          if data =~ /^Enter password:/
             channel.send_data "#{mysql_admin_pass}\n"
           end
        end
      end

      task :set_admin_password do
        begin
          run "mysqladmin -u root password #{mysql_admin_pass}" 
        rescue 
          logger.important "could not change admin password"
        end
      end
            
    end
  end
end

#
# Setup replication
#

# setup user for repl
# GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%.yourdomain.com' IDENTIFIED BY 'slavepass';

# get current position of binlog
# mysql> FLUSH TABLES WITH READ LOCK;
# Query OK, 0 rows affected (0.00 sec)
# 
# mysql> SHOW MASTER STATUS;
# +------------------+----------+--------------+------------------+
# | File             | Position | Binlog_Do_DB | Binlog_Ignore_DB |
# +------------------+----------+--------------+------------------+
# | mysql-bin.000012 |      296 |              |                  | 
# +------------------+----------+--------------+------------------+
# 1 row in set (0.00 sec)
# 
# # get current data
# mysqldump --all-databases --master-data >dbdump.db
# 
# UNLOCK TABLES;


# Replication Features and Issues
# http://dev.mysql.com/doc/refman/5.0/en/replication-features.html
