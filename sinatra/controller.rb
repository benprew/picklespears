#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'user'
require 'division'
require 'team'

get '/' do
  erb :index
end

post '/search' do
  teams = Team.find(:all,
                    :conditions => [ "name like ?", '%' + params[:team].upcase + '%' ],
                    :order => "name")

  if teams.length == 0
    print "<h1> No teams found </h1>"
  elsif teams.length == 1
    redirect('/team?team_id='+teams[0].id.to_s)
  else
    erb :search
  end
end

get '/browse' do
  divisions = Division.find(:all,
                            :conditions => [ 'league = ?', params[:league]]).sort { |a, b| a.name <=> b.name }
  erb :browse, :locals => { :divisions => divisions }
end

get '/team' do
  team = Team.find(params[:team_id])

  erb :team_home, :locals => { :team => team }
end
