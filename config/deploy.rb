role :app, 'throwingbones.com'

set :application, "picklespears"
set :user, 'throwingbones'

# set :domain, "#{user}@throwingbones.com"
set :deploy_to, "/var/www/picklespears"

set :scm, :git
set :scm_command, '/usr/local/git/bin/git'
set :local_scm_command, `which git`.chomp
set :repository, 'git://github.com/benprew/picklespears.git'
set :branch, 'master'
set :deploy_via, :remote_cache

set :app_port, 10000
set :app_name, 'picklespears.rb'
set :web, "apache"
set :use_sudo, false

set :shared_files, [ 'config/database.yml' ]
 
