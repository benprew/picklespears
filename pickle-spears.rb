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
      @player = Player.get(session[:player_id])
      @name = @player.name
    end
  end

  get '/' do
    haml :index
  end
  
  get '/browse' do
    @divisions = Division.all(:league => params[:league], :order => [:name.asc])
    @league = params[:league]
    haml :browse
  end

  get '/player' do
    @player = Player.get(params[:id] || session[:player_id])
    haml :player
  end

  get '/player/sign_in' do
    @errors = params[:errors]
    haml :sign_in
  end

  post '/player/create' do
    player = Player.new

    if params[:password] != params[:password2]
      @errors = "Password do not match"
      redirect "/player/sign_in?errors=#{@errors}"
    end

    attributes = params
    attributes.delete(:password2)
    player.attributes = attributes

    begin
      player.save
    rescue StandardError => err
      if /Duplicate entry/.match(err)
        @errors = "Player name '#{params[:name]}' already exists, please choose another"
      else
        @errors = "Unknown error occured, please contact 'coach@throwingbones.com'"
      end
    end

    if @errors
      redirect "/player/sign_in?errors=#{@errors}"
    end

    session[:player_id] = player.id
    redirect '/player'
  end

  post '/player/sign_in' do
    player = Player.login(params[:email_address], params[:password])

    if !player
      @errors = "Incorrect login or password (login: '#{params[:email_address]}' password: '#{params[:password]}')"
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
    @team = Team.get(params[:team_id])
  
    haml :team_home
  end

  get '/search' do
    @teams = Team.all(:name.like => '%' + params[:team].upcase + '%', :order => [:name.asc])

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

  get '/game/attending_status' do
    pg = @player.players_games.get(params[:game_id])
    if !pg
      pg = PlayersGame.new(:player_id => @player.id, :game_id => params[:game_id])
    end
    p pg
    pg.update_attributes(:status => params[:status])
    pg.save

    "Status #{params[:status]} recorded"
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

