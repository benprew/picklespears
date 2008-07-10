#!/usr/local/ruby/bin/ruby

require 'rubygems'
require 'daemons'

pwd = '/var/www/html/pickle-spears/sinatra'
production = (ARGV.last == 'production')
Daemons.run_proc('pickle-spears.rb', :log_output => 1, :dir_mode => :system) do
  Dir.chdir(pwd)
  if production
    exec "ruby pickle-spears.rb -e production"
  else
    exec "ruby pickle-spears.rb"
  end
end
