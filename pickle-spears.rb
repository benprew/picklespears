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
      @name = Player.find(session[:player_id]).name
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

  get '/player' do
    @player = Player.find(params[:id] || session[:player_id])
    haml :player
  end

  get '/player/sign_in' do
    @errors = params[:errors]
    haml :sign_in
  end

  post '/player/create' do
  end

  post '/player/sign_in' do
    player = nil
    begin
      player = Player.login(params[:email_address], params[:password])
    rescue
      @errors = "Incorrect login or password user: '#{params[:email_address]}' password: '#{params[:password]}'"
    end

    if !player
      @errors = "Incorrect login or password user: '#{params[:email_address]}' password: '#{params[:password]}'"
      haml :sign_in
    else
      session[:player_id] = player.id
      redirect "/player?id=#{player.id}"
    end
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

  def href(url, args)
    # assumes you're using haml to do escaping
    return "#{url}?" + (args.map { |key, val| "#{key}=#{escape_once(val)}"}).join(";")
  end
end

