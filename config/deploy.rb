#default_run_options[:pty] = true
ssh_options[:forward_agent] = false

# Using GIT to deploy...
#set :scm, "git"
#set :scm_passphrase, "Galo50Pintado" #This is your custom users password
#set :branch, "master"
#set :git_shallow_clone, 1     # only copy the most recent, not the entire repository

# Using COPY to deploy...
set :scm, :none
set :deploy_via, :copy
set :copy_exclude, %w(.git/* log/* tmp/* test/* .gitignore ._* .DS_Store)

set :user, "root"
set :use_sudo, false

set :application, "galinha-on-rails"
set :repository,  "/Users/alexandrepiccolo/Sites/rails/galinha-on-rails"
set :deploy_to, "/var/www/rails_apps/#{application}"
#set :deploy_via, :remote_cache
set :keep_releases, 5

role :web, "XXXCNN4006.hospedagemdesites.ws"                          # Your HTTP server, Apache/etc
role :app, "XXXCNN4006.hospedagemdesites.ws"                          # This may be the same as your `Web` server
role :db,  "XXXCNN4006.hospedagemdesites.ws", :primary => true        # This is where Rails migrations will run

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

before "deploy:restart", "deploy:set_ownership_and_permissions"
#after  "deploy:web:enable", "deploy:restart"
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    #run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
    run "/etc/init.d/apache2 restart"
  end
  
  # Muda as permissoes
  task :set_ownership_and_permissions, :roles => :app do
    run "chown -R www-data:www-data #{deploy_to}/current/*"
    run "chmod -R 755 #{deploy_to}/current/*"
  end
  
  
  namespace :web do
    desc "Present a maintenance page to visitors"
    task :disable, :roles => :web, :except => { :no_release => true } do
      on_rollback { run "rm -Rf #{deploy_to}/system" }
      run "mkdir #{deploy_to}/current/public/system; cp #{deploy_to}/current/public/maintenance.html #{deploy_to}/current/public/system/maintenance.html"
      run "chown -R www-data:www-data #{deploy_to}/current/public/system/maintenance.html"
    end
    
    desc "Remove maintenance page"
    task :enable, :roles => :web, :except => { :no_release => true } do
      run "rm -Rf #{deploy_to}/current/public/system"
    end
    
    desc "Restart apache web-server"
    task :restart, :roles => :web, :except => { :no_release => true } do
      run "/etc/init.d/apache2 restart"
    end
  end
  
end

namespace :firewall do
  # Baixa o firewall
  task :down, :roles => :app do
    run "cd /root/bin;./firewall.down"
  end
  
  # Levanta o firewall
  task :up, :roles => :app do
    run "cd /root/bin;./firewall.up"
  end
end