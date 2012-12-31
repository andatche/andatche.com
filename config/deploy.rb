# Target directory for the application on the web and app servers.
set(:deploy_to) { File.join("", "var", "www", "sites", application) }

set :deploy_via, :remote_cache
set :scm, :git
set :repository, "git@github.com:andatche/andatche.com.git"

set :application, "andatche.com"
set :user, "ubuntu"
server "andatche.com", :app, :web, :db, :primary => true

default_run_options[:pty] = true

ssh_options[:forward_agent] = true

set :use_sudo, false

namespace :deploy do
  task :finalize_update do
    run "mkdir -p #{shared_path}/bundle"
    run "cd #{latest_release} && bundle install --deployment --path #{shared_path}/bundle/vendor"
    run "cd #{latest_release} && bundle exec nanoc compile"
  end
  task :restart do
  end
end
