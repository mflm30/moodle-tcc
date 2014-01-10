# -*- encoding : utf-8 -*-
require 'bundler/capistrano'
require 'capistrano-db-tasks'
require 'new_relic/recipes'
require 'airbrake/capistrano'

# Capistrano Multistage
set :stages, %w(production staging)
set :default_stage, 'staging'
require 'capistrano/ext/multistage'

# Whenever (crontab)
set :whenever_variables, defer { "stage=#{stage}" }
set :whenever_command, 'bundle exec whenever'
set :whenever_identifier, defer { "#{application}_#{stage}" }
require 'whenever/capistrano'

set :application, 'tcc.unasus.ufsc.br'
set :repository,  'git@gitlab.setic.ufsc.br:tcc-unasus/sistema-tcc.git'
set :scm, :git

set :default_environment, {'LANG' => 'pt_BR.UTF-8'}
set :git_enable_submodules, true

set :ssh_options, {forward_agent: true, port: '2200'}

set :use_sudo, false
set :deploy_via, :remote_cache
set :rails_env, 'production'

namespace :deploy do
  task :setup_db, :roles => :db, :desc => 'Configura base de dados inicial.' do
    strategy.deploy!
    linka_dependencias
    bundle.install
    run "cd #{release_path} && #{rake} db:create RAILS_ENV=#{rails_env}"
  end

  task :start do ; end
  task :stop do ; end

  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  after 'deploy:finalize_update', 'deploy:linka_dependencias'
  task :linka_dependencias, :roles => :app, :desc => 'Faz os links simbólicos com arquivos de configuração' do
    run "ln -s #{File.join(deploy_to, 'shared', 'database.yml')} #{File.join(current_release, 'config', 'database.yml')}"
    run "ln -s #{File.join(deploy_to, 'shared', 'moodle.yml')} #{File.join(current_release, 'config', 'moodle.yml')}"
    run "ln -s #{File.join(deploy_to, 'shared', 'newrelic.yml')} #{File.join(current_release, 'config', 'newrelic.yml')}"
    run "ln -s #{File.join(deploy_to, 'shared', 'tcc_config.yml')} #{File.join(current_release, 'config', 'tcc_config.yml')}"
    run "ln -s #{File.join(deploy_to, 'shared', 'errbit.yml')} #{File.join(current_release, 'config', 'errbit.yml')}"
    run "ln -s #{File.join(deploy_to, 'shared', 'email.yml')} #{File.join(current_release, 'config', 'email.yml')}"
    run "ln -s #{File.join(deploy_to, 'shared', 'uploads')} #{File.join(current_release, 'public', 'uploads')}"
  end
end
