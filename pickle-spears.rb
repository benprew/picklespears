#!/usr/local/ruby/bin/ruby

$:.unshift File.dirname(__FILE__) + '/sinatra/lib'

require 'sinatra'
require 'division'
require 'team'
require 'time'
require 'player'

set :root, Dir.pwd
set :views, Dir.pwd + '/views'
set :public, Dir.pwd + '/public'
set :sessions, true

class PickleSpears

  before do
    if session[:player_id]
      @player = Player.find(session[:player_id])
      @name = @player.name
    end
  end

  get '/' do
    haml :index
  end
  
  get '/browse' do
    @divisions = Division.find_all_by_league(params[:league], :order => 'name')
    @league = params[:league]
    haml :browse
  end

  get '/sign_in' do
    haml :sign_in
  end

  post '/sign_in' do
    begin
      player = Player.login(params[:email_address], params[:password])
    rescue
      @errors = "Incorrect login or password"
      haml :sign_in
    end
    session[:player_id] = @player.object_id
    redirect "/player?id=#{@player.object_id.to_s}"
  end
  
  get '/sign_out' do
    session[:player_id] = nil
    redirect '/'
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
      redirect "/team?team_id=#{@teams[0].id.to_s}"
    else
      haml :search
    end
  end

  get '/stylesheet.css' do
    headers 'Content-Type' => 'text/css'
    sass :stylesheet
  end
end

helpers do
  def title(title=nil)
      @title = title unless title.nil?
      @title
  end
end

