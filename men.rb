#!/usr/local/ruby/bin/ruby

require 'cgi'
require 'erb'
require 'lib/schedule'

cgi = CGI.new("html4")

schedule = Schedule.new()

divisions = schedule.divisions_and_teams_for_group("Men")

print cgi.header("type" => "text/html")

ERB.new(File.read("browse.rhtml")).run
