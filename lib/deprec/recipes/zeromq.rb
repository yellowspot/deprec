Capistrano::Configuration.instance(:must_exist).load do 
  namespace :zeromq do 

      desc "zeromq instalacija, s podrskom za multicasting"
      task :install do
        next unless capture("if[ -e /usr/local/lib/libzmq.so ]; then echo 'installed' ; fi").empty?
        zeromq_src = {:url => "http://download.zeromq.org/zeromq-2.1.7.tar.gz",
          :configure => "./configure --with-pgm"}
        deprec2.download_src(zeromq_src, src_dir)
        deprec2.install_from_src(zeromq_src, src_dir)  
      end

  end
end
