class PickleSpears < Sinatra::Application
  before '*' do
    @season = Season[params[:id]] if params[:id]
  end

  post '/season/create' do
    season = Season.create(params.slice(:name, :start_date))
    redirect uri_for(season, 'edit')
  end

  post '/season/edit' do
    @season.update(params.slice(:name, :start_date)).save
    flash[:success] = "Season updated"
    redirect uri_for(@season, 'edit')
  end

  post '/season/add_exception_day' do
    if !@season
      flash[:errors] = "Invalid season"
      redirect '/season/list'
    end

    if params[:delete]
      holiday = SeasonException[params[:delete]]
      flash[:success] = "Removed holiday #{holiday.description} on #{holiday.date}"
      holiday.delete

      redirect uri_for(@season, 'edit')
    else
      SeasonException.new(
        {
          date: params[:date],
          season_id: params[:id],
          description: params[:description]
        }
      ).save
      flash[:success] = "Added holiday on #{params[:date]}"
      redirect uri_for(@season, 'edit')
    end
  end

  post '/season/add_league' do
    @league = League[params[:league_id]]
    @teams = @league.divisions_with_upcoming_games.map(&:teams_with_upcoming_games).flatten(1)

    flash[:success] = "Added #{@teams.length} teams from league #{@league.name}"

    @teams.each { |t| @season.add_team(t) unless @season.teams.include?(t) }

    redirect uri_for(@season, 'edit')
  end

  post '/season/remove_team' do
    @team = Team[params[:team_id]]
    @season.remove_team(@team)
    flash[:success] = "Removed team #{@team.name}"
    redirect uri_for(@season, 'edit')
  end

  post '/season/update_team' do
    @team = Team[params[:team_id]]
    @team.update(params.slice(:name, :manager_name, :manager_email, :manager_phone_no, :division_id))

    params[:preferred_day].each do |day|
      SeasonPreferredDay.find_or_create(team_id: @team.id, season_id: @season.id, preferred_day_of_week: day)
    end if params[:preferred_day]

    params[:day_to_avoid].each do |day|
      next if day == ""
      day = Date.strptime(day, '%Y-%m-%d')
      warn "day #{day}"
      SeasonDayToAvoid.find_or_create(team_id: @team.id, season_id: @season.id, day_to_avoid: day)
    end

    flash[:success] = "Updated team #{@team.name}"
    redirect uri_for(@season, 'edit')
  end

  post '/season/create_team' do
    @team = Team.create(params.slice(:name, :manager_name, :manager_email, :manager_phone_no, :division_id))
    # build season explicitly because we're posting from a team view, so we
    # specify season_id to refer to the id instead of the usual id
    @season = Season[params[:season_id]]
    @season.add_team(@team)

    params[:preferred_day].each do |day|
      SeasonPreferredDay.create(team: @team, season: @season, preferred_day_of_week: day)
    end if params[:preferred_day]

    params[:day_to_avoid].each do |day|
      next if day == ""
      SeasonDayToAvoid.create(team: @team, season: @season, day_to_avoid: day)
    end

    flash[:success] = "Created team #{@team.name}"
    redirect uri_for(@season, 'edit')
  end

  post '/season/create_schedule' do
    flash[:success] = "Schedule queued to build, you will receive an email when it is complete"
    send_email( to: 'benprew@gmail.com', subject: "Schedule queued for season #{@season.name}" )
    redirect uri_for(@season)
  end
end
