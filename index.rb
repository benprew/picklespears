#!/usr/local/ruby/bin/ruby

require 'erb'
require 'lib/user'
require 'cgi'

cgi = CGI.new()

print cgi.header("type" => "text/html")

user = User.new("bob")

ERB.new(File.read("index.rhtml")).run
