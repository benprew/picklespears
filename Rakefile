require 'rubygems'

$ruby         = `which ruby`.chomp
$pid_file     = '/var/run/pickle-spears'
$server       = 'mongrel'
$environment  = 'production'

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
    File.open('pickle-spears.d', 'w') do |f|
      f << File.read('pickle-spears.d.in') % [ Dir.pwd ]
    end
    sh 'cp -f pickle-spears.d /etc/init.d/pickle-spears'
    sh 'chmod +x /etc/init.d/pickle-spears'
    sh 'rm pickle-spears.d'
  end

  task :at_boot => :install do
    sh 'ln -sf ../init.d/pickle-spears /etc/rc.d/rc2.d/S95pickle-spears'
    sh 'ln -sf ../init.d/pickle-spears /etc/rc.d/rc2.d/K15pickle-spears'
  end
end
