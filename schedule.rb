#!/usr/local/ruby/bin/ruby

require 'cgi'
require 'lib/schedule'

cgi = CGI.new("html4")

sch = Schedule.new()

if cgi.has_key?('team')
  sch.print_schedule_for(cgi['team'], cgi['division'])
else
  sch.choose_team()
end

