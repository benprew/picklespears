class PickleSpears < Sinatra::Application
  get '/division/schedule_games' do
    haml :schedule_games
  end

  get '/division/list' do
    divisions = Division.order(:name).all.select { |d| d.teams_with_upcoming_games.length > 0 }
    haml '/division/list'.to_sym, locals: { divisions: divisions }
  end

  get '/division' do
    @divisions = Division.order(:name).all.select { |d| d.teams_with_upcoming_games.length > 0 }
    @games = Game.where(teams: Team.where(division: Division[params[:division_id]]) ).order(:date)

    haml 'division/index'.to_sym
  end
end
