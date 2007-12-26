#!/usr/local/ruby/bin/ruby

require 'cgi'
require 'team'
require 'erb'
require 'uri'

cgi = CGI.new("html4")

teams = Team.select { |team| cgi['team'] && team.name =~ /#{cgi['team']}/i }

if teams.length == 0
  print cgi.header("type" => "text/html")
  print "<h1> No teams found </h1>"
elsif teams.length == 1
#   print cgi.header("type" => "text/html")
#   print "<h1> redirect to single team </h1>"
#   p teams
  # print this.header( { 'Status' => '302 Moved', 'location' =>'#{where}' } )
  print cgi.header( { 'Status' => '302 Moved', 'location' =>'browse.rb?team=' + URI.escape(teams[0].name) } )
else
  print cgi.header("type" => "text/html")
  ERB.new(File.read("search.rhtml")).run
end
