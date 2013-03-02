class PickleSpears < Sinatra::Application
  get '/season/list' do
    @seasons = Season.all
    haml 'season/list'.to_sym
  end

  before '*' do
    @season = Season[params[:season_id]] if params[:season_id]
  end

  get '/season' do
    redirect '/season/list' unless params[:season_id]

    @season = Season[params[:season_id]] if params[:season_id]
    @divisions = Division.order(:name).all.select { |d| d.teams_with_upcoming_games.length > 0 }

    haml :'season/index'
  end

  get '/season/edit' do
    @leagues = League.order{ :name }.all
    @divisions = Division.order(:name).all.select { |d| d.teams_with_upcoming_games.length > 0 }

    haml :'season/edit'
  end

  post '/season/edit' do
    @season.update(params.slice(:name, :start_date)).save
    flash[:success] = "Season updated"
    redirect url_for '/season/edit', { season_id: @season.id }
  end

  post '/season/add_exception_day' do
    if !@season
      flash[:errors] = "Invalid season"
      redirect '/season'
    end

    if params[:delete]
      SeasonException[params[:delete]].delete
      flash[:success] = "Removed holiday on #{params[:delete]}"
      redirect url_for '/season/edit', { season_id: @season.id }
    else
      SeasonException.new(params.slice(:date, :season_id, :description)).save
      flash[:success] = "Added holiday on #{params[:date]}"
      redirect url_for '/season/edit', { season_id: @season.id }
    end
  end

  post '/season/create_schedule' do
    flash[:success] = "Schedule queued to build, you will receive an email when it is complete"
    send_email( to: 'benprew@gmail.com', subject: 'Schedule queued for season #{@season.name}' )
    redirect url_for '/season', { season_id: @season.id }
  end

  post '/season/add_league' do
    @league = League[params[:league_id]]
    @teams = @league.divisions_with_upcoming_games.map(&:teams_with_upcoming_games).flatten(1)

    flash[:success] = "Added #{@teams.length} teams from league #{@league.name}"

    current_teams = @season.teams

    @teams.each { |t| @season.add_team(t) unless @season.teams.include?(t) }

    redirect url_for '/season/edit', { season_id: @season.id }
  end

  post '/season/remove_team' do
    @team = Team[params[:team_id]]
    @season.remove_team(@team)
    flash[:success] = "Removed team #{@team.name}"
    redirect url_for '/season/edit', { season_id: @season.id }
  end

  post '/season/update_team' do
    @team = Team[params[:team_id]]
    @team.update(params.slice(:name, :manager_name, :manager_email, :manager_phone_no, :division_id))

    params[:preferred_day].each do |day|
      SeasonPreferredDay.find_or_create(team_id: @team.id, season_id: @season.id, preferred_day_of_week: day)
    end if params[:preferred_day]

    params[:day_to_avoid].each do |day|
      next if day == ""
      day = Date.strptime(day, '%m/%d/%Y')
      warn "day #{day}"
      SeasonDayToAvoid.find_or_create(team_id: @team.id, season_id: @season.id, day_to_avoid: day)
    end

    flash[:success] = "Updated team #{@team.name}"
    redirect url_for '/season/edit', { season_id: @season.id }
  end

  get '/season/create_team' do
    @divisions = Division.order(:name).all.select { |d| d.teams_with_upcoming_games.length > 0 }

    haml 'team/create'.to_sym
  end

  post '/season/create_team' do

    @team = Team.create(params.slice(:name, :manager_name, :manager_email, :manager_phone_no, :division_id))
    @season.add_team(@team)

    params[:preferred_day].each do |day|
      SeasonPreferredDay.create(team: @team, season: @season, preferred_day_of_week: day)
    end if params[:preferred_day]

    params[:day_to_avoid].each do |day|
      next if day == ""
      SeasonDayToAvoid.create(team: @team, season: @season, day_to_avoid: day)
    end

    flash[:success] = "Created team #{@team.name}"
    redirect url_for '/season/edit', { season_id: @season.id }
  end

  get '/season/create' do
    @leagues = League.order{ :name }.all
    haml 'season/create'.to_sym
  end

  get '/season/games' do
    @division = Division[params[:division_id]]
    @games = Game.where( id: DB[%q{ SELECT g.id FROM games g
      INNER JOIN teams_games tg ON (g.id = tg.game_id)
      INNER JOIN teams t on (tg.team_id = t.id)
      WHERE g.season_id = ? AND t.division_id = ?
      GROUP BY g.id }, @season.id, @division.id]).sort{ |a, b| a.date <=> b.date }

    haml 'season/games'.to_sym
  end

  post '/season/create' do
    season = Season.new
    season.name = params[:season_name]
    season.start_date = params[:start_date]
    season.save
    redirect url_for '/season/edit', { season_id: season.id }
  end
end
