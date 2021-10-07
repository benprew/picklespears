# frozen_string_literal: true

before do
  logger.info "user_id: #{session[:player_id]}"
  @user = Player[session[:player_id]] if session[:player_id]
end

get '/:model/:method' do
  view = "#{params[:model]}/#{params[:method]}"
  model = params[:model].classify.constantize
  obj = load_obj(model, params)
  render_args = {}
  render_args[:layout] = false if params[:layout] == 'false'

  logger.info("routing #{params[:model]} #{params[:method]} to #{view} with #{obj}")

  halt 404, "#{params[:model]} not found" if params[:id] && !obj

  args = {}
  args[params[:model]] = obj if obj
  args_method = "#{params[:method]}_args"

  args = model.send(args_method, params) if model.respond_to?(args_method)

  slim view.to_sym, locals: args, **render_args
end

def load_obj(model, params)
  return model[params[:id]] if params[:id]

  nil
end

require_relative 'game'
require_relative 'league'
require_relative 'player'
require_relative 'season'
require_relative 'team'
include Icalendar
require 'tzinfo'
require 'icalendar/tzinfo'

helpers do
  def is_league_manager?
    @user && @user.is_league_manager?
  end

  def ical_calendar(team)
    calendar = Calendar.new
    calendar.x_wr_calname = team.name

    timezones = {}

    team.games.sort_by(&:date).each do |game|
      calendar.event do |e|
        event_start = game.date.to_datetime
        tzid = 'America/Los_Angeles'
        tz = TZInfo::Timezone.get tzid
        timezone = tz.ical_timezone event_start
        timezones[timezone.to_ical] = timezone

        e.dtstart = Icalendar::Values::DateTime.new event_start, 'tzid' => tzid
        e.dtend = Icalendar::Values::DateTime.new (game.date + 1.hours).to_datetime, 'tzid' => tzid
        e.summary = game.description
        e.description = game.description
        e.uid = "http://#{APP_DOMAIN}/game/#{game.id}/"
      end
    end

    timezones.values { |t| calendar.add_timezone t }

    content_type :'text/calendar'
    calendar.to_ical
  end
end
