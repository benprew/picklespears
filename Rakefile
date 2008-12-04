require 'rubygems'

$ruby         = `which ruby`.chomp
$pid_file     = '/var/run/pickle-spears'
$server       = 'mongrel'
$environment  = 'production'
$executable   = 'pickle-spears.rb'
$daemon_name  = 'pickle-spears'
$executable_dir = Dir.pwd
$port         = 4567

desc 'Install pickle-spears as a daemon and run it at boot.'
task :daemonize => 'daemon:at_boot' do
  sh '/etc/init.d/pickle-spears start' do |successful, _|
    if successful
      puts '=> Point your browser at http://0.0.0.0:4567 and start to use your wiki!'
    else
      'Something went wrong.'
    end
  end
end

namespace :daemon do
  task :install do
    File.open('daemon.d', 'w') do |f|
      f << File.read('daemon.d.in') % [ $executable_dir, $executable, "-p #{$port}" ]
    end
    sh 'cp -f daemon.d /etc/init.d/' + $daemon_name
    sh 'chmod +x /etc/init.d/' + $daemon_name 
    sh 'rm daemon.d'
  end

  task :at_boot => :install do
    sh 'ln -sf ../init.d/pickle-spears /etc/rc.d/rc2.d/S95' + $daemon_name
    sh 'ln -sf ../init.d/pickle-spears /etc/rc.d/rc2.d/K15' + $daemon_name
  end
end
