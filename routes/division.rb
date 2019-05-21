class PickleSpears < Sinatra::Application
  get '/division/schedule_games' do
    haml :schedule_games
  end

  get '/division/list' do
    divisions = Division.order(:name).all.select { |d| d.teams_with_upcoming_games.length > 0 }
    haml '/division/list'.to_sym, locals: { divisions: divisions }
  end

  get '/division' do
    division_id = params[:division_id].to_i
    @division = Division[division_id]

    redirect '/division/list' unless @division

    @divisions = Division.order(:name).all.select { |d| d.teams_with_upcoming_games.length > 0 }
    @games = Game.where(teams: Team.where(division: @division)).where{ date >= Date.today }.order(:date)

    haml :'division/index'
  end
end
