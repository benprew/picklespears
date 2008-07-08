#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'user'
require 'division'
require 'team'

class PickleSpearsController

  get '/' do
    haml :index
  end
  
  get '/browse' do
    @divisions = Division.find_all_by_league(params[:league], :order => 'name')
    haml :browse
  end

  get '/sign_in' do
    haml :sign_in
  end
  
  get '/team' do
    @team = Team.find(params[:team_id])
  
    haml :team_home
  end

  get '/search' do
    @teams = Team.find(:all, :conditions => [ "name like ?", '%' + params[:team].upcase + '%' ], :order => 'name')

    if @teams.length == 0
      haml "%h1 No @teams found"
    elsif @teams.length == 1
      redirect "team?team_id=#{@teams[0].id.to_s}"
    else
      haml :search
    end
  end

  get '/stylesheet.css' do
    content_type 'text/css', :charset =&gt; 'utf-8'
    sass :stylesheet
  end
end
