# frozen_string_literal: true

require 'tzinfo'
require 'icalendar'
require 'icalendar/tzinfo'

before do
  logger.info "user_id: #{session[:player_id]}"
  @user = Player[session[:player_id]] if session[:player_id]
end

before '/:model/*' do
  model = mk_class(params)
  @item = load_obj(model, params) if model
end

get '/:model/:method' do
  exec_route params
end

get '/:model/:id/:method' do
  exec_route params
end

def exec_route(params)
  logger.info("routing #{params[:model]} #{params[:method]} with #{params[:id]}")

  view = "#{params[:model]}/#{params[:method]}"

  model = mk_class(params)
  halt 404 unless model

  obj = load_obj(model, params)
  halt 404, "#{params[:model]} not found" if params[:id] && !obj

  render_args = {}
  render_args[:layout] = false if params[:layout] == 'false'

  args = {}
  args[params[:model]] = obj if obj
  args_method = "#{params[:method]}_args"

  args = model.send(args_method, params) if model.respond_to?(args_method)

  slim view.to_sym, locals: args, **render_args
end

def mk_class(params)
  params[:model].classify.constantize
rescue NameError
  nil
end

def load_obj(model, params)
  return model[params[:id]] if params[:id] && params[:id] =~ /^[0-9]+$/

  nil
end

require_relative 'game'
require_relative 'league'
require_relative 'player'
require_relative 'season'
require_relative 'team'

helpers do
  def ical_calendar(team)
    calendar = Icalendar::Calendar.new
    calendar.x_wr_calname = team.name

    timezones = {}
    tzid = 'America/Los_Angeles'
    tz = TZInfo::Timezone.get tzid

    team.games.sort_by(&:date).each do |game|
      calendar.event do |e|
        event_start = game.date.to_datetime
        timezone = tz.ical_timezone event_start
        timezones[timezone.to_ical] = timezone

        e.dtstart = Icalendar::Values::DateTime.new event_start, 'tzid' => tzid
        e.dtend = Icalendar::Values::DateTime.new (game.date + 1.hours).to_datetime, 'tzid' => tzid
        e.summary = game.description
        e.description = game.description
        e.uid = "http://#{APP_DOMAIN}/game/#{game.id}/"
      end
    end

    timezones.each_value { |t| calendar.add_timezone t }

    content_type :'text/calendar'
    calendar.to_ical
  end
end
