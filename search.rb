#!/usr/local/ruby/bin/ruby

require 'cgi'
require 'lib/teams'

cgi = CGI.new("html4")

teams = Team.select { |team| team.name =~ /cgi['team']/ }

if !teams
  print cgi.header("type" => "text/html")
  print "<h1> No teams found </h1>"
elsif teams.length == 1
  print cgi.header("type" => "text/html")
  print "<h1> redirect to single team </h1>"
  p teams
  # redirect to browse for team
else
  print cgi.header("type" => "text/html")
  ERB.new(File.read("search.rhtml")).run
end
