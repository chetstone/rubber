
namespace :rubber do

  namespace :nginx do
  
    rubber.allow_optional_tasks(self)
  
    before "rubber:install_packages", "rubber:nginx:custom_install"
    
    task :custom_install, :roles => :web do
      # need to add list of sources to get a newer nginx (includes fair balancer)
      srcs = <<-SOURCES
        deb http://ppa.launchpad.net/calmkelp/ubuntu hardy main
        deb-src http://ppa.launchpad.net/calmkelp/ubuntu hardy main
      SOURCES
      srcs.gsub!(/^ */, '') # remove leading whitespace
      put(srcs, '/etc/apt/sources.list.d/nginx.list')      
    end  
  
    # serial_task can only be called after roles defined - not normally a problem, but
    # rubber auto-roles don't get defined till after all tasks are defined
    on :load do
      rubber.serial_task self, :serial_restart, :roles => :web do
        run "/etc/init.d/nginx restart"
      end
      rubber.serial_task self, :serial_reload, :roles => :web do
        run "/etc/init.d/nginx reload"
      end
    end
    
    before "deploy:stop", "rubber:nginx:stop"
    after "deploy:start", "rubber:nginx:start"
    after "deploy:restart", "rubber:nginx:serial_restart"
    
    desc "Stops the nginx web server"
    task :stop, :roles => :web, :on_error => :continue do
      run "/etc/init.d/nginx stop"
    end
    
    desc "Starts the nginx web server"
    task :start, :roles => :web do
      run "/etc/init.d/nginx start"
    end
    
    desc "Restarts the nginx web server"
    task :restart, :roles => :web do
      serial_restart
    end
  
    desc "Reloads the nginx web server"
    task :reload, :roles => :web do
      serial_reload
    end
  
  end

end
