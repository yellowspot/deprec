Capistrano::Configuration.instance(:must_exist).load do
  namespace :deploy do

    #ovaj task stvara log,public,tmp/pids ovdje ga override-am da to ne radi
    task :finalize_update, :except => { :no_release => true } do    
    end

  end
end
