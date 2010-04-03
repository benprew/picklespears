#!/usr/local/ruby/bin/ruby

$:.unshift File.dirname(__FILE__) + '/lib'

require 'rubygems'
require 'pony'
require 'dm-core'
require 'sinatra'
require 'haml'
require 'sass'

require 'erb'

# open id
gem 'ruby-openid', '>=2.1.2'
require 'openid'
require 'openid/store/filesystem'

require 'picklespears/db'
require 'division'
require 'team'
require 'time'
require 'player'

set :sessions, true

class PickleSpears

  configure :test do
    set :root, File.dirname(__FILE__)
    set :views,File.dirname( __FILE__) + '/views'
    set :public,File.dirname( __FILE__) + '/public'
  end

  configure :production do
    set :root, Dir.pwd
    set :views, Dir.pwd + '/views'
    set :public, Dir.pwd + '/public'
  end

  before do
    if session[:player_id]
      p session[:player_id]
      @player = Player.get(session[:player_id])
      @name = @player.name
    end

    @errors = params[:errors]
    @messages = params[:messages]
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
    @player_from_request = Player.get(params[:id] || session[:player_id])
    haml :player
  end

  get '/player/create' do
    @errors = params[:errors]
    haml :player_create
  end

  post '/player/create' do
    @player = Player.new
    attrs = params
    attrs.delete(:create_account)
    attrs.delete('create_account')

    begin
      @player.fupdate(attrs)
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


################

  get '/login' do    
    haml :login
  end

  get '/login/openid' do
    openid = params[:openid_identifier]
    begin
      oidreq = openid_consumer.begin(openid)
    rescue OpenID::DiscoveryFailure => why
      "Sorry, we couldn't find your identifier '#{openid}'"
    else
      # You could request additional information here - see specs:
      # http://openid.net/specs/openid-simple-registration-extension-1_0.html
      # oidreq.add_extension_arg('sreg','required','nickname')
      # oidreq.add_extension_arg('sreg','optional','fullname, email')
      
      # Send request - first parameter: Trusted Site,
      # second parameter: redirect target
      redirect oidreq.redirect_url(root_url, root_url + "/login/openid/complete")
    end
  end

  get '/login/openid/complete' do
    oidresp = openid_consumer.complete(params, request.url)
    openid = params[:openid_identifier]

    case oidresp.status
      when OpenID::Consumer::FAILURE
        "Sorry, we could not authenticate you with the identifier '#{openid}'."

      when OpenID::Consumer::SETUP_NEEDED
        "Immediate request failed - Setup Needed"

      when OpenID::Consumer::CANCEL
        "Login cancelled."

      when OpenID::Consumer::SUCCESS
        player = Player.first(:openid => oidresp.identity_url)
        if player
          session[:player_id] = player.id
          redirect '/player'
        else
          player = Player.create(:openid => oidresp.identity_url, :name => '')
          player.save
          session[:player_id] = player.id
          redirect url_for('/player/edit', :messages => "You have just created an account, please edit your information")
        end
    end
  end

#############

  get '/player/edit' do
    haml :player_edit
  end

  post '/player/update' do
    attrs = params
    attrs.delete(:update)
    attrs.delete('update')
    begin
      @player.fupdate(attrs)
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

  get '/team/edit' do
    @team = Team.get(params[:team_id])
    @divisions = Division.all()
    
    haml :team_edit
  end

  post '/team/update' do
    @team = Team.get(params[:team_id])
    @team.name = params[:name]
    @team.division_id = params[:division_id]
    @team.save

    redirect url_for("/team", { :team_id => params[:team_id], :message => "Team updated!" })
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
    response['Content-Type'] = 'text/css'
    sass :stylesheet
  end

  post '/players_team/delete' do
    PlayersTeam.first( :player_id => params[:player_id], :team_id => params[:team_id] ).destroy
    team = Team.first( :id => params[:team_id])
    @message = "You have successfully left #{team.name}"
    redirect sprintf('/player?messages=%s', URI.escape(@message))
  end

  get '/player/attending_status_for_game' do
    game_id = params[:game_id]
    @status = params[:status]
    @player_from_request = Player.get(params[:player_id])
    @player_from_request.set_attending_status_for_game(Game.get(game_id), @status)
    haml :attending_status_for_game
  end

  # Meant to be called via ajax
  get '/game/attending_status' do
    @player.set_attending_status_for_game(Game.get(params[:game_id]), params[:status])
    "Status #{params[:status]} recorded"
  end

  get '/send_game_reminders' do
    output = ''
    Team.all.each do |team|
      next_game = team.next_game()
      output += "\n<br/> working on team #{team.name} ..."

      # skip if more then 4 days away
      if !next_game || next_game.date > ( Date.today() + 4 ) || next_game.reminder_sent
        output += "no upcoming unreminded games"
        next
      end

      output += "sending email about #{next_game.description}"
 
      next_game.reminder_sent = true
      next_game.save

      team.players.each do |player|
        @player = player
        @game = next_game

        next unless (player.email_address and player.email_address.match(/@/))

        info = {
          :from    => 'ben.prew@gmail.com',
          :to      => player.email_address,
          :subject => "Next Game: #{@game.description}",
          :body    => haml(:reminder, :layout => false),
          :content_type => 'text/html',
        }
        if production?
          Pony.mail(info)
        else
          p info
        end
      end
    end
    template :foo do
      output
    end
    haml :foo
  end
end

helpers do

  def title(title=nil)
    @title ||= ''
    @title = title unless title.nil?
    @title
  end

  def url_for(url, args)
    return "#{url}?" + (args.map { |key, val| "#{key}=#{URI.escape(val.to_s)}"}).join(";")
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

  def openid_consumer
    @openid_consumer ||= OpenID::Consumer.new(session,
      OpenID::Store::Filesystem.new("#{File.dirname(__FILE__)}/tmp/openid"))  
  end

  def root_url
    request.url.match(/(^.*\/{2}[^\/]*)/)[1]
  end

end

