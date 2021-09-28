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
  if model.respond_to?(args_method)
    args = model.send(args_method, params)
  end

  slim view.to_sym, locals: args, **render_args
end

def load_obj(model, params)
  return model[params[:id]] if params[:id]

  return nil
end

require_relative 'game'
require_relative 'league'
require_relative 'player'
require_relative 'season'
require_relative 'team'
include Icalendar

helpers do
  def is_league_manager?
    @user && @user.is_league_manager?
  end

  def ical_calendar(team)

    tzid = 'America/Los_Angeles'
    calendar = Calendar.new
    calendar.x_wr_calname = team.name
    calendar.timezone do |t|
      t.tzid = tzid

      t.daylight do |d|
        d.dtstart      = '20130310T020000'
        d.rrule        = "FREQ=YEARLY;BYMONTH=4;BYDAY=1SU"
        d.tzoffsetfrom = '-0800'
        d.tzoffsetto   = '-0700'
        d.tzname       = 'PDT'
      end

      t.standard do |s|
        s.dtstart      = '20131103T020000'
        s.rrule        = "FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU"
        s.tzoffsetfrom = '-0700'
        s.tzoffsetto   = '-0800'
        s.tzname       = 'PST'
      end
    end

    team.games.each do |game|
      calendar.event do |e|
        e.dtstart = Icalendar::Values::DateTime.new game.date.to_datetime, { TZID: tzid }
        e.dtend = Icalendar::Values::DateTime.new (game.date + 1.hours).to_datetime, { TZID: tzid }
        e.summary = game.description
        e.description = game.description
        e.uid = "http://#{APP_DOMAIN}/game/#{game.id}/"
      end
    end

    content_type :'text/calendar'
    calendar.to_ical
  end
end
