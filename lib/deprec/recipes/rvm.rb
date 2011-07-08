Capistrano::Configuration.instance(:must_exist).load do 
  namespace :deprec do
    namespace :rvm do

      #TODO this will not install newer version if one already exists on the server
      #simply exists if rvm is found
      task :install do
        next if capture("type rvm | head -1") =~ /rvm is \/usr\/local\/bin\/rvm/

        install_deps
        deprec2.download_src({:url => "https://rvm.beginrescueend.com/install/rvm"})
        run "#{sudo} chmod +x #{src_dir}/rvm"
        run "#{sudo} #{src_dir}/rvm"
      end
  
      task :install_deps do
        deprec::git::install
        apt.install({:base => %w(curl build-essential bison openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev
)}, :stable)        
      end

      task :install_rubies do
        list = capture "rvm list"
        next if list =~ /ruby-1\.8\.7/ && list =~ /ruby-1\.9\.2/
        
        run "#{sudo} rvm install 1.8.7"
        run "#{sudo} rvm install 1.9.2"
        run "#{sudo} rvm use 1.8.7 --default"
      end
    end
  end
end
