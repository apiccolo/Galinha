#default_run_options[:pty] = true
ssh_options[:forward_agent] = false

# Using GIT to deploy...
#set :scm, "git"
#set :scm_passphrase, "Galo50Pintado" #This is your custom users password
#set :branch, "master"

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
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
  
  # Muda as permissoes
  task :set_ownership_and_permissions, :roles => :app do
    run "chown -R www-data:www-data #{deploy_to}/current/*"
    run "chmod -R 755 #{deploy_to}/current/*"
  end
end