# config valid only for current version of Capistrano
lock '3.3.5'

set :application, 'SpreeAppOne'
set :repo_url, 'https://github.com/forever-ram/SpreeAppOne.git'

# Set tmp directory for application deployment
set :tmp_dir, "/tmp"

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('/tmp/log', 'tmp/pids', 'tmp/sockets')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :default_setup do
  desc 'Create database.yml and secrets file.yml'
  task :database_and_secrets do
    on roles(:app) do
      execute "mkdir #{shared_path}/config -p"
      execute "touch #{shared_path}/config/database.yml"
      execute "touch #{shared_path}/config/secrets.yml"
    end
  end
end

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_puma_dirs_files do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
      execute "mkdir #{shared_path}/log -p"
      execute "touch #{shared_path}/tmp/sockets/puma.sock"
      execute "touch #{shared_path}/tmp/pids/puma.pid"
      execute "touch #{shared_path}/log/puma_error.log"
      execute "touch #{shared_path}/log/puma_access.log"
    end
  end

  before :start, :make_puma_dirs_files
end

namespace :deploy do
  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end
end

before "deploy:check", "default_setup:database_and_secrets"
