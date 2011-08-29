Capistrano::Configuration.instance(:must_exist).load do 
  namespace :rvm do

    #TODO this will not install newer version if one already exists on the server
    #simply exists if rvm is found
    task :install do
      #next if capture("type rvm | head -1") =~ /rvm is \/usr\/local\/bin\/rvm/

      install_deps
      deprec2.download_src({:url => "https://rvm.beginrescueend.com/install/rvm"})
      run "#{sudo} chmod +x #{src_dir}/rvm"
      run "#{sudo} #{src_dir}/rvm"
      rvm::install_rubies
    end
    
    task :install_deps do
      deprec::git::install
      apt.get %w(curl build-essential bison openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev)
    end

    task :upgrade do
      run "#{sudo} #{rvm_bin_path}/rvm get head"
      run "#{sudo} #{rvm_bin_path}/rvm reload"
    end
    
    task :install_rubies do
      list = capture "#{rvm_bin_path}/rvm list"
      rubies = %w(ruby-1.8.7-p352 ruby-1.9.2-p290 ree-1.8.7-2011.03)

      rubies.each do |ruby|
        unless list.include? ruby
          run "#{sudo} #{rvm_bin_path}/rvm install #{ruby}"
        end
      end        
    end

  end
end
