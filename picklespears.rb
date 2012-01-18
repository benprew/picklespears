#!/usr/local/ruby/bin/ruby

require 'bundler/setup'
require 'pony'
require 'sinatra'
require 'sinatra/config_file'
require 'haml'
require 'sass'
require 'time'

config_file 'config/config.yml'

class PickleSpears < Sinatra::Application
  set :haml, :ugly => true, :format => :html5

  enable :sessions
  # Must be done after sessions
  require 'rack/openid'
  use Rack::OpenID

  configure :test do
    set :sessions, false
  end

  configure :production do
    set :clean_trace, true
  end

  before do
    if session[:player_id]
      @player = Player[session[:player_id]]
      @name = @player.name
    end

    @errors = params[:errors]
    @messages = params[:messages]
  end

  get '/schedule' do

  end

  get '/' do
    @teams = []
    if @player
      redirect '/player'
    else
      haml :index
    end
  end

  get '/browse' do
    @divisions = Division.filter(:league => params[:league]).order(:name.asc).all
    @league = params[:league]
    haml :browse
  end

################ OpenID login

  get '/login' do
    haml :login
  end

  post '/login/openid' do
    if resp = request.env["rack.openid.response"]
      if resp.status == :success
        player = Player.first(:openid => resp.identity_url)
        if player
          session[:player_id] = player.id
          redirect '/player'
        else

          @player = Player.create(:openid => resp.identity_url, :name => 'Unknown player', :email_address => 'none@none.com')
          @messages = "You have just created an account, please edit your information"
          session[:player_id] = @player.id
          haml :user_edit
        end
      else
        "Error: #{resp.status}"
      end
    else
      headers 'WWW-Authenticate' => Rack::OpenID.build_header(
        :identifier => params["openid_identifier"]
      )
      throw :halt, [401, 'got openid?']
    end
  end

##############

  get '/sign_out' do
    session[:player_id] = nil
    redirect '/'
  end

  get '/stylesheet.css' do
    response['Content-Type'] = 'text/css'
    sass :stylesheet
  end

  post '/players_team/delete' do
    PlayersTeam.filter( :player_id => params[:player_id], :team_id => params[:team_id] ).delete
    team = Team[params[:team_id]]
    @message = "You have successfully left #{team.name}"
    redirect sprintf('/player?messages=%s', URI.escape(@message))
  end

  # Meant to be called via ajax
  get '/game/attending_status' do
    @player.set_attending_status_for_game(Game[params[:game_id]], params[:status])
    "Status #{params[:status]} recorded"
  end

  get '/send_game_reminders' do
    output = ''
    Team.all.each do |team|
      next_game = team.next_game()
      output += "\n<br/> working on team #{team.name} ..."

      # skip if more then 4 days away
      if !next_game || next_game.date > ( Date.today.to_time + 4 ) || next_game.reminder_sent
        output += "no upcoming unreminded games"
        next
      end

      output += "sending email about #{next_game.description}"

      next_game.reminder_sent = true
      next_game.save

      team.players.each do |player|
        next unless (player.email_address and player.email_address.match(/@/))

        info = {
          :from    => 'ben.prew@gmail.com',
          :to      => player.email_address,
          :subject => "Next Game: #{next_game.description}",
          :body    => haml(:reminder, :layout => false, :locals => { :player => player, :game => next_game }),
          :content_type => 'text/html',
          :via => :smtp,
          :via_options => {
	    :address => 'smtp.sendgrid.net',
	    :port => '587',
	    :domain => 'heroku.com',
	    :user_name => ENV['SENDGRID_USERNAME'],
	    :password => ENV['SENDGRID_PASSWORD'],
	    :authentication => :plain,
	    :enable_starttls_auto => true
          }
        }
        if production?
          Pony.mail(info)
        else
          p info
        end
      end
    end
    template :output do
      output
    end
    haml :output
  end
end

helpers do

  def title(title=nil)
    @title ||= ''
    @title = title unless title.nil?
    @title
  end

  def url_for(url, args)
    return "#{url}?" + (args.map { |key, val| "#{key}=#{URI.escape(val.to_s)}"}).join("&")
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

  def root_url
    request.url.match(/(^.*\/{2}[^\/]*)/)[1]
  end
end

require_relative 'routes/init'
require_relative 'models/init'


