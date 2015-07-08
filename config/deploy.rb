require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
# require 'mina/rbenv'  # for rbenv support. (http://rbenv.org)
require 'mina/rvm'    # for rvm support. (http://rvm.io)
#require 'mina_sidekiq/tasks'

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

env = ENV['on'] || 'production'

set :domain, 'callific-bank'
set :deploy_to, '/home/ubuntu/callific-bank'
set :repository, 'git@github.com:joshsoftware/callific-bank.git'
set :branch, 'master'
set :user, 'ubuntu'
set :ssh_options, '-A'
set :rail_env, 'production'

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths,
    [
      'config/mongoid.yml', 'config/secrets.yml', 'log', 'public/uploads', 
      'config/sidekiq.yml', 'config/elasticsearch.yml', 'config/aws_keys.yml'
    ]

# Optional settings:
#   set :user, 'foobar'    # Username in the server to SSH to.
#   set :port, '30000'     # SSH port number.

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .rbenv-version to your repository.
  # invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  # invoke :'rvm:use[ruby-1.9.3-p125@default]'
  invoke :'rvm:use[ruby-2.2.1]'
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]

  queue! %[mkdir -p "#{deploy_to}/shared/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]

  queue! %[mkdir -p "#{deploy_to}/shared/public/uploads"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/public/uploads"]

  queue! %[mkdir -p "#{deploy_to}/shared/public/uploads/sheets"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/public/uploads/sheets"]

  queue! %[touch "#{deploy_to}/shared/config/mongoid.yml"]
  queue  %[echo "-----> Be sure to edit 'shared/config/mongoid.yml'."]
  
  queue! %[touch "#{deploy_to}/shared/config/secrets.yml"]
  queue  %[echo "-----> Be sure to edit 'shared/config/secrets.yml'."]

  queue! %[touch "#{deploy_to}/shared/config/sidekiq.yml"]
  queue  %[echo "-----> Be sure to edit 'shared/config/sidekiq.yml'."]

  queue! %[touch "#{deploy_to}/shared/config/elasticsearch.yml"]
  queue  %[echo "-----> Be sure to edit 'shared/config/elasticsearch.yml'."]

  queue! %[touch "#{deploy_to}/shared/config/aws_keys.yml"]
  queue  %[echo "-----> Be sure to edit 'shared/config/aws_keys.yml'."]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    #invoke :'sidekiq:quiet'
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    #invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'

    to :launch do
      queue "mkdir -p #{deploy_to}/current/tmp"
      
      # uncomment to use whenever
      #queue "cd #{deploy_to}/current && RAILS_ENV=#{env} bundle exec whenever --clear-crontab"
      #queue "cd #{deploy_to}/current && RAILS_ENV=#{env} bundle exec whenever --write-crontab"
      
      queue "touch #{deploy_to}/current/tmp/restart.txt"
      #invoke :'sidekiq:restart'

      queue "sudo monit restart sidekiq"
    end
  end
end

desc "Seed data to the database"
task :seed => :environment do
  queue "cd #{deploy_to}/#{current_path}/"
  queue "bundle exec rake db:seed RAILS_ENV=#{rails_env}"
  queue  %[echo "-----> Rake Seeding Completed."]
end

# For help in making your deploy script, see the Mina documentation:
#
#  - http://nadarei.co/mina
#  - http://nadarei.co/mina/tasks
#  - http://nadarei.co/mina/settings
#  - http://nadarei.co/mina/helpers
