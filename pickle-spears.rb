#!/usr/local/ruby/bin/ruby

$:.unshift File.dirname(__FILE__) + '/sinatra/lib'

require 'sinatra'
require 'rubygems'
require 'dm-core'

require 'division'
require 'team'
require 'time'
require 'player'


set :root, Dir.pwd
set :views, Dir.pwd + '/views'
set :public, Dir.pwd + '/public'
set :sessions, true

configure :test do
  DataMapper.setup(:default, 'sqlite3:///tmp/test_db')
  DataMapper.auto_migrate!
end

configure :production do
  DataMapper.setup(:default, 'mysql://rails_user:foo@localhost/rails_development')
end

configure :development do
  DataMapper.setup(:default, 'mysql://rails_user:foo@localhost/rails_development')
end

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
      @errors = "Passwords '#{params[:password]}' and '#{params[:password2]}' do not match"
      redirect "/player/sign_in?errors=#{@errors}"
    end

    attributes = params
    attributes.delete('password2')
    player.attributes = attributes

    begin
      player.save
    rescue StandardError => err
      if /Duplicate entry/.match(err)
        @errors = "Player name '#{params[:name]}' already exists, please choose another"
      elsif /may not be/.match(err)
        @errors = err
      else
        @errors = "Unknown error occured, please contact 'coach@throwingbones.com'" + err
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

  get '/player/edit' do
    haml :player_edit
  end

  post '/player/update' do
    player = @player

    if params[:password] != params[:password2]
      @errors = "Passwords '#{params[:password]}' and '#{params[:password2]}' do not match"
      redirect "/player/edit?errors=#{@errors}"
    end

    attributes = params
    attributes.delete('password2')
    player.attributes = attributes

    begin
      player.save
    rescue StandardError => err
      if /Duplicate entry/.match(err)
        @errors = "Player name '#{params[:name]}' already exists, please choose another"
      elsif /may not be/.match(err)
        @errors = err
      else
        @errors = "Unknown error occured, please contact 'coach@throwingbones.com'" + err
      end
    end
    redirect '/player'
  end
  
  get '/sign_out' do
    session[:player_id] = nil
    redirect '/'
  end

  get '/team' do
    @team = Team.get(params[:team_id])
  
    haml :team_home
  end

  # Meant to be an ajax call
  get '/team/join' do
    @player.join_team(Team.get(params[:team_id]))
    "Joined!"
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

  # Meant to be called via ajax
  get '/game/attending_status' do
    @player.set_attending_status_for_game(Game.get(params[:game_id]), params[:status])
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

  def status_for_game(player, game)
    return '' unless player && game && player.is_on_team?(game.team)
    pg = PlayersGame.first(:player_id => player.id, :game_id => game.id)

    if pg
      return %{<div>Going: <strong>#{pg.status}</strong> <a href="#" onclick="document.getElementById('status_#{game.id}').style.display = 'block'">[change]</a>} + attending_status_div(game, 'none') + "</div>"
    else
      attending_status_div(game)
    end
  end

  def attending_status_div(game, initial_display_type='block')
    return <<-HTML
     <div id="status_#{game.id}" style="display:#{initial_display_type}">
       <strong>Going?</strong>
       <a href='#' onclick="set_attending_status('#{game.id}', 'yes', 'status_#{game.id}'); return false;">Yes</a>
       <a href='#' onclick="set_attending_status('#{game.id}', 'no', 'status_#{game.id}'); return false;">No</a>
       <a href='#' onclick="set_attending_status('#{game.id}', 'maybe', 'status_#{game.id}'); return false;">Maybe</a>
     </div>
    HTML
  end

  def user_edit_partial
    haml :user_edit, :layout => false
  end
end

