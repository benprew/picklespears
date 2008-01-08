#!/usr/local/ruby/bin/ruby

require 'cgi'
require 'team'
require 'erb'
require 'uri'

cgi = CGI.new("html4")

teams = Team.find(:all, :conditions => [ "name like ?", '%' + cgi['team'].upcase + '%' ], :order => "name")

if teams.length == 0
  print cgi.header("type" => "text/html")
  print "<h1> No teams found </h1>"
elsif teams.length == 1
  print cgi.header( { 'Status' => '302 Moved', 'location' =>'browse.rb?team_id=' + teams[0].id.to_s } )
else
  print cgi.header("type" => "text/html")
  ERB.new(File.read("search.rhtml")).run
end
