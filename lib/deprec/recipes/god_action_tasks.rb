Capistrano::Configuration.instance(:must_exist).load do
  namespace :deploy do

    [:start, :stop, :restart].each do |action|
      desc "#{action} service #{application}"
      task action do
        run "#{sudo} #{god_bin} #{action.to_s} #{application}"
      end
    end

  end
end
