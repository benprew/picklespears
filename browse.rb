#!/usr/local/ruby/bin/ruby

require 'cgi'
require 'erb'
require 'division'
require 'team'

cgi = CGI.new("html4")


if cgi.has_key?('team_id')
  team = Team.find(cgi['team_id'])
  print cgi.header("type" => "text/html")
  ERB.new(File.read("team_home.rhtml")).run
else
  divisions = Division.find(:all, :conditions => [ 'league = ?', cgi['league']]).sort { |a, b| a.name <=> b.name }
  print cgi.header("type" => "text/html")
  ERB.new(File.read("browse.rhtml")).run
end
