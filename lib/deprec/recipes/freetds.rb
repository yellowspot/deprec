Capistrano::Configuration.instance(:must_exist).load do
  namespace :freetds do

    desc "Install freetds"
    task :install do
      apt.get %w(freetds-bin freetds-common freetds-dev libct4 libsybdb5)
      initial_config
    end

    SYSTEM_CONFIG_FILES[:freetds] = 
      [  
       { :template => 'freetds.conf',
         :path => '/etc/freetds/freetds.conf',
         :mode => 0644,
         :owner => 'root:root'}
      ]

    desc "Generate initial configs and copy direct to server."
    task :initial_config do
      SYSTEM_CONFIG_FILES[:freetds].each do |file|
        deprec2.render_template(:freetds, file.merge(:remote => true))
      end
    end

  end
end
