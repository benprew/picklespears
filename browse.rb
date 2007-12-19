#!/usr/local/ruby/bin/ruby

require 'cgi'
require 'erb'
require 'lib/schedule'

cgi = CGI.new("html4")

schedule = Schedule.new()

if cgi.has_key?('team')
  schedule.schedule_for_team(cgi['team'])
else
  divisions = schedule.divisions_and_teams_for_group(cgi['group'])
  print cgi.header("type" => "text/html")
  ERB.new(File.read("browse.rhtml")).run
end
