# Copyright 2006-2008 by Mike Bailey. All rights reserved.
Capistrano::Configuration.instance(:must_exist).load do 

  namespace :deprec do
    namespace :mri do
            
      SRC_PACKAGES['ruby-1.8.7-p330'] = {
        :md5sum => "50a49edb787211598d08e756e733e42e  ruby-1.8.7-p330.tar.gz",
        :url => "ftp://ftp.ruby-lang.org/pub/ruby/1.8/ruby-1.8.7-p330.tar.gz",
        :deps => %w(zlib1g-dev libssl-dev libncurses5-dev libreadline5-dev),
        :configure => "./configure --with-readline-dir=/usr/local;"
      }

      SRC_PACKAGES['ruby-1.9.2-p180'] = {
        :md5sum => "0d6953820c9918820dd916e79f4bfde8  ruby-1.9.2-p180.tar.gz", 
        :url => "http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p180.tar.gz",
        :deps => %w(zlib1g-dev libssl-dev libncurses5-dev libreadline5-dev),
        :configure => "./configure",
        :post_install => 'sudo gem update --system'
      }

      SRC_PACKAGES['ruby-1.9.3-p0'] = {
        :md5sum => "0d6953820c9918820dd916e79f4bfde8  ruby-1.9.3-p0.tar.gz", 
        :url => "http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p0.tar.gz",
        :deps => %w(zlib1g-dev libssl-dev libncurses5-dev libreadline5-dev libyaml-dev),
        :configure => "./configure",
        :post_install => 'sudo gem update --system',
        :version_string => "ruby 1.9.3p0"
      }

      src_package_options = SRC_PACKAGES.keys.select{|k| k.match /^ruby-\d\.\d\.\d/ }
      set(:mri_src_package) { 
        puts "Select mri_src_package from list:"
        Capistrano::CLI.ui.choose do |menu|
          menu.choices(*src_package_options)
        end
      }

      desc "Install Ruby"
      task :install do
        if capture("ruby -v; exit 0").include?(SRC_PACKAGES[mri_src_package][:version_string])
          logger.info "Ruby #{SRC_PACKAGES[mri_src_package][:version_string]} is already installed"
          next
        end
        deprec2.download_src(SRC_PACKAGES[mri_src_package])
        deprec2.install_from_src(SRC_PACKAGES[mri_src_package])
      end
      
    end
  end
  
end
