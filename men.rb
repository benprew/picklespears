#!/usr/local/ruby/bin/ruby

require 'cgi'
require 'erb'
require 'lib/schedule'

cgi = CGI.new("html4")

schedule = Schedule.new()

if cgi.has_key?('team')
  schedule.print_schedule_for(cgi['team'], cgi['division'])
else
  divisions = schedule.divisions_and_teams_for_group("Men")
  print cgi.header("type" => "text/html")
  ERB.new(File.read("browse.rhtml")).run
end
