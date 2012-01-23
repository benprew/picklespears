class PickleSpears < Sinatra::Application
  get '/team' do
    @team = Team[params[:team_id]]

    haml :team_home
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

    redirect url_for("/team", { :team_id => params[:team_id], :message => "Team updated!" })
  end

  # Meant to be an ajax call
  get '/team/join' do
    @player.join_team(Team[params[:team_id]])
    "Joined!"
  end

  get '/team/search' do
    if params[:team]
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
end
