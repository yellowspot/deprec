Capistrano::Configuration.instance(:must_exist).load do 

  desc "install ntp and set timezone to Zagreb"
  task :timezone do  
    apt.get "ntp"
    run "#{sudo} sh -c 'echo \"Europe/Zagreb\" > /etc/timezone'"
    run "#{sudo} dpkg-reconfigure -f noninteractive tzdata"
  end

end
