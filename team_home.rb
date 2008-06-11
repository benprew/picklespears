#!/usr/local/ruby/bin/ruby

require 'cgi'
require 'erb'
require 'division'
require 'team'
require 'date'

cgi = CGI.new("html4")

print cgi.header("type" => "text/html")
team = Team.find(cgi['team_id'])
ERB.new(File.read("team_home.rhtml")).run

