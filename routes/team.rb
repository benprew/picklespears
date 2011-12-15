class PickleSpears
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

  get '/team/search' do
    @teams = Team.all(:name.like => '%' + params[:team].upcase + '%', :order => [:name.asc])

    @errors = "No teams found" if @teams.length == 0

    if @teams.length == 1
      redirect "/team?team_id=#{@teams[0].id.to_s}"
    else
      haml :search
    end
  end



end