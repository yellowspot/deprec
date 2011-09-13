Capistrano::Configuration.instance(:must_exist).load do
  namespace :config do

    desc "Generate configuration file(s) from template(s)"
    task :generate do
      project_config_files.each do|file|
        deprec2.render_template("", file)
      end
    end

    desc "Push config files to server"
    task :push do
      deprec2.push_configs("", project_config_files)
      project_config_files.each do |file|
        if file[:symlink_to]
          deprec2.mkdir(File.dirname(file[:symlink_to]), :via => :sudo)
          sudo "rm -f #{file[:symlink_to]}"
          sudo "ln -sf #{file[:path]} #{file[:symlink_to]}"
        end
      end
    end

  end
end
