role :app, 'teamvite.com'

set :application, "teamvite"
set :user, 'throwingbones'

# set :domain, "#{user}@throwingbones.com"
set :deploy_to, "/var/www/teamvite"

set :scm, :git
set :scm_command, '/usr/bin/git'
set :local_scm_command, `which git`.chomp
set :repository, 'git://github.com/benprew/picklespears.git'
set :branch, 'origin/master'

set :use_sudo, false
