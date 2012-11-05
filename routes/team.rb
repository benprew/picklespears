class PickleSpears < Sinatra::Application
  get '/team' do
    @team = Team[params[:team_id]]

    haml :team_home
  end

  get '/team/calendar' do
    @team = Team[params[:team_id]]
    haml :team_calendar
  end

  get '/team/edit' do
    @team = Team[params[:team_id]]
    @divisions = Division.all()

    haml :team_edit
  end

  post '/team/update' do
    @team = Team[params[:team_id]]
    @team.name = params[:name]
    @team.division_id = params[:division_id]
    @team.save

    flash[:messages] = "Team updated!"

    redirect url_for("/team", { :team_id => params[:team_id] })
  end

  # Meant to be an ajax call
  get '/team/join' do
    @player.add_team(Team[params[:team_id]])
    "Joined!"
  end

  get '/team/search' do
    if params[:team]
      @query = params[:team]
      @teams = Team.filter(:name.like '%' + params[:team].upcase + '%').order(:name.asc).all
    else
      @teams = []
    end

    @errors = "No teams found" if params[:team] && @teams.length == 0

    if @teams.length == 1
      redirect "/team?team_id=#{@teams[0].id.to_s}"
    else
      partial :search
    end
  end

  post '/team/:team_id/add_player' do
    @player = Player.find_or_create(:email_address => params[:email]) { |p| p.name = params[:name] }
    @team = Team[params[:team_id]]
    @divisions = Division.all()

    @errors = "Unable to find/create player." unless @player
    @errors << "Unable to find team." unless @team

    if (@player && @team)
      if @team.players.include?(@player)
        flash[:messages] = "Player \"#{@player.name}\" already on roster, not re-adding"
      else
        @team.add_player(@player)
        flash[:messages] = "Player \"#{@player.name}\" added"
      end
    end

    # TODO: send email to user to register

    haml :team_edit
  end
end
