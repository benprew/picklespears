#!/usr/local/ruby/bin/ruby

$:.unshift File.dirname(__FILE__) + '/sinatra/lib'

require 'sinatra'
require 'rubygems'
require 'dm-core'
require 'mailer'

require 'division'
require 'team'
require 'time'
require 'player'

set :sessions, true

configure :test do
  set :root, File.dirname(__FILE__)
  set :views,File.dirname( __FILE__) + '/views'
  set :public,File.dirname( __FILE__) + '/public'
  DataMapper.setup(:default, 'sqlite3:///tmp/test_db')
  DataMapper.auto_migrate!
end

configure :development do
  DataMapper.setup(:default, 'sqlite3:///tmp/dev_db')
end

configure :production do
  set :root, Dir.pwd
  set :views, Dir.pwd + '/views'
  set :public, Dir.pwd + '/public'
  DataMapper.setup(:default, 'mysql://rails_user:foo@localhost/rails_development')

  Sinatra::Mailer.config = {
    :host   => 'smtp.throwingbones.com',
    :port   => '25',              
    :user   => 'throwingbones',
    :pass   => '0aefe114',
    :auth   => :plain, # :plain, :login, :cram_md5, the default is no auth
    :domain => "localhost.localdomain" # the HELO domain provided by the client to the server 
  }

end

class PickleSpears

  before do
    if session[:player_id]
      @player = Player.get(session[:player_id])
      @name = @player.name
    end

    @errors = params[:errors]
  end

  get '/' do
    @teams = []
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

  get '/player/create' do
    @errors = params[:errors]
    haml :player_create
  end

  post '/player/create' do
    @player = Player.new

    begin
      @player.update_attributes(params)
    rescue StandardError => err
      @errors = err
    end

    if @errors
      haml :player_create
    else
      session[:player_id] = @player.id
      redirect '/player/join_team'
    end
  end

  get '/player/join_team' do
    @teams = []
    @teams = Team.all(:name.like => '%' + params[:team].upcase + '%', :order => [:name.asc]) if params[:team]
    haml :join_team
  end

  post '/player/sign_in' do
    player = Player.login(params[:email_address], params[:password])

    if !player
      @errors = "Incorrect login or password (login: '#{params[:email_address]}' password: '#{params[:password]}')"
      @teams = []
      haml :index
    else
      session[:player_id] = player.id
      redirect "/player"
    end
  end

  get '/player/edit' do
    haml :player_edit
  end

  post '/player/update' do
    begin
      @player.update_attributes(params)
    rescue StandardError => err
      @errors = err
    end

    redirect @errors ? "/player?errors=#{@errors}" : '/player'
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
      redirect '/?errors="No teams found"'
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

  get '/player/send_game_reminder' do
    @player = Player.first(params[:player_id])
    @game = Game.first(params[:game_id])
    info = {
      :from    => 'coach@picklespears.com',
      :to      => @player.email_address,
      :subject => 'Game Reminder from PickleSpears.com',
      :body    => haml(:reminder)
    }
    email(info)
    
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

