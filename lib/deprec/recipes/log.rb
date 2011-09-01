Capistrano::Configuration.instance(:must_exist).load do
  namespace :log do

    desc "tail production log file" 
    task :tail, :roles => :app do
      trap("INT") { puts 'Interupted'; exit 0; } 
      run "tail -f -n 200 #{log_file_path}" do |channel, stream, data|
        puts data
        break if stream == :err
      end
    end

  end
end
