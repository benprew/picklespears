class PickleSpears < Sinatra::Application
  include Icalendar

  before '/team/:team_id/*' do
    begin
      @team = Team[params[:team_id]]
    rescue Sequel::DatabaseError
      halt 404
    end
    halt 404 unless @team
  end

  get '/team' do
    begin
      @team = Team[params[:team_id]]
    rescue Sequel::DatabaseError
      halt 404
    end

    unless @team
      flash[:errors] = 'No team with that id was found'
      redirect '/team/search'
    end

    haml :'team/index'
  end

  get '/team/:team_id/calendar' do
    haml 'team/calendar'.to_sym
  end

  get '/team/edit' do
    @team = Team[params[:team_id]]
    @divisions = Division.all
    @redirect_to = params[:redirect_to]

    haml 'team/edit'.to_sym
  end

  post '/team/update' do
    @team = Team[params[:team_id]]
    @team.name = params[:name]
    @team.division_id = params[:division_id]
    @team.save

    flash[:messages] = 'Team updated!'

    redirect params[:redirect_to] ||
      url_for('/team', { team_id: params[:team_id] })
  end

  # Meant to be an ajax call
  get '/team/join' do
    @player.add_team(Team[params[:team_id]])
    'Joined!'
  end

  get '/team/search' do
    if params[:team]
      @query = params[:team]
      @teams = Team.filter(Sequel.like(:name, '%' + params[:team].upcase + '%')).order(Sequel.asc(:name)).all
    else
      @teams = []
    end

    @errors = 'No teams found' if params[:team] && @teams.length == 0

    if @teams.length == 1
      redirect url_for('/team', { team_id: @teams[0].id })
    else
      haml 'team/search'.to_sym
    end
  end

  post '/team/:team_id/add_player' do
    @player = Player.find_or_create(:email_address => params[:email]) { |p| p.name = params[:name] }
    @divisions = Division.all()

    @errors = "Unable to find/create player." unless @player

    if (@player && @team)
      if @team.players.include?(@player)
        flash[:messages] = "Player \"#{@player.name}\" already on roster, not re-adding"
      else
        @team.add_player(@player)
        flash[:messages] = "Player \"#{@player.name}\" added"
      end
    end

    # TODO: send email to user to register
    haml 'team/edit'.to_sym
  end

  tzid = 'America/Los_Angeles'

  get '/team/:team_id/calendar.ics' do
    calendar = Calendar.new
    calendar.x_wr_calname = @team.name
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

    @team.games.each do |game|
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
