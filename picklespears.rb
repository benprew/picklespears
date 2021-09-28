#!/usr/local/ruby/bin/ruby

require 'bundler/setup'
require 'pony'
require 'sinatra'
require 'sinatra/config_file'
require 'slim'
require 'sass'
require 'time'
require 'rack-flash'
require 'bcrypt'
require 'digest'
require 'prawn'
require 'icalendar'
require 'active_support/all'

# Slim::Engine.options[:pretty] = true

config_file 'config/config.yml'

APP_DOMAIN = 'www.teamvite.com'

class PickleSpears < Sinatra::Application
  enable :sessions
  use Rack::Flash, accessorize: %i[errors messages]

  DATE_FORMAT = '%a %b %e %I:%M %p'

  # this should be enabled by default in Sinatra::Application subclasses
  # http://sinatrarb.com/intro.html - see Logging
  configure :production, :development do
    enable :logging
  end

  configure :production do
    set :clean_trace, true

    error 400 do
      'Invalid Request'
    end

    error do
      send_email to: 'ben.prew@gmail.com', subject: 'error on teamvite.com',
                 body: "#{request.env['sinatra.error'].message} #{request.inspect}"
      'Application error.'
    end
  end

  not_found do
    'This page was not found'
  end

  error 403 do
    'Access forbidden'
  end

  get '/' do
    @teams = []
    slim :index, layout: false
  end

  get '/browse' do
    league_id = params[:league_id].to_i
    @divisions = Division.filter(league_id: league_id).order(Sequel.asc(:name)).all
    @league = League[league_id]

    unless @league
      flash[:errors] = 'No league with that name was found'
      redirect '/team/search'
    end

    slim :browse
  end

  get '/stylesheet.css' do
    response['Content-Type'] = 'text/css'
    sass :stylesheet
  end

  post '/players_team/delete' do
    team = Team[params[:team_id]]
    team.remove_player(@user)
    flash[:messages] = "You have successfully left #{team.name}"
    redirect uri_for(@user)
  end

  get '/send_game_reminders' do
    output = ''
    Team.all.each do |team|
      next_game = team.next_game()
      output += "\n<br/> working on team #{team.name} ..."

      if !next_game || next_game.date > (Date.today + 5).to_time
        output += 'no upcoming unreminded games'
        next
      end

      output += "sending email about #{next_game.description}"

      team.players.each do |player|
        next unless player.email_address and player.email_address.match(/@/)

        pg = PlayersGame.find_or_create(player_id: player.id, game_id: next_game.id)

        next if pg.reminder_sent

        send_email(
          to: player.email_address,
          subject: "Next Game: #{next_game.date.strftime(DATE_FORMAT)} #{next_game.description} ",
          body: partial(:reminder, locals: { player: player, game: next_game }),
          content_type: 'text/html'
        )

        pg.reminder_sent = true
        pg.save
      end
    end
    slim output
  end
end

helpers do
  def title(title = nil)
    @title ||= ''
    @title = title unless title.nil?
    @title
  end

  def uri_for(item, method = 'index', args: {})
    id = item.id
    args[:id] = id
    route = item.class.name.downcase
    # id or method could be null, so we compact then join
    uri = '/' + [route, method].compact.join('/')
    [uri, mk_params(args)].compact.join('?')
  end

  def mk_params(args)
    (args.map { |key, val| "#{key}=#{URI.escape(val.to_s)}" }).join('&')
  end

  def url_for(url, args = {})
    "#{url}?" + mk_params(args)
  end

  def send_email(options)
    message = {
      from: 'team@teamvite.com',
      via: :smtp,
      via_options: {
        address: ENV['MAILGUN_SMTP_SERVER'],
        port: ENV['MAILGUN_SMTP_PORT'],
        user_name: ENV['MAILGUN_SMTP_LOGIN'],
        password: ENV['MAILGUN_SMTP_PASSWORD'],
        domain: 'teamvite.com',
        enable_starttls_auto: true
      }
    }.merge(options)

    if settings.environment == :production
      Pony.mail(message)
    elsif settings.environment != :test
      p message
    end
  end

  def partial(page, variables = {})
    if File.exist?("#{settings.views}/#{page}.slim")
      slim page.to_sym, { layout: false }.merge(variables)
    else
      slim :"partials/#{page}", { layout: false }.merge(variables)
    end
  end
end

require_relative 'routes/init'
require_relative 'models/init'
