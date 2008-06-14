#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'erb'
require 'user'

get '/' do
  user = User.new("bob")
  ERB.new(File.read('index.rhtml')).run
end
