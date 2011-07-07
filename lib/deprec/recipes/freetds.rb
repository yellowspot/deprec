Capistrano::Configuration.instance(:must_exist).load do 
  namespace :deprec do
    namespace :freetds do
      task :install do
        apt.install({:base => %w(freetds-bin freetds-common freetds-dev libct4 libsybdb5)}, :stable)
      end
    end
  end
end
