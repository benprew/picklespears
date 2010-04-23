require 'rake'
require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  ENV['RACK_ENV'] = 'test'
  t.test_files = FileList['test/test_*.rb']
  t.verbose = true
end

executable     = 'pickle-spears.rb'
daemon_name    = 'pickle-spears'
executable_dir = Dir.pwd
port           = 4567

desc "Install #{daemon_name} as a daemon and run it at boot."
task :daemonize => 'daemon:at_boot' do
  if system "/etc/init.d/#{daemon_name} start"
    puts "=> Point your browser at http://0.0.0.0:#{port} to use your app!"
  else
    puts 'Something went wrong.'
  end
end

namespace :daemon do
  task :install do
    File.open('daemon.d', 'w') do |f|
      f << File.read('daemon.d.in') % [ executable_dir, executable, "-p #{port}" ]
    end
    `cp -f daemon.d /etc/init.d/#{daemon_name}`
    `chmod +x /etc/init.d/#{daemon_name}`
    `rm daemon.d`
  end

  task :at_boot => :install do
    `ln -sf ../init.d/pickle-spears /etc/rc.d/rc2.d/S95#{daemon_name}`
    `ln -sf ../init.d/pickle-spears /etc/rc.d/rc2.d/K15#{daemon_name}`
  end
end
