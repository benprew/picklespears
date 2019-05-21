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

    unless @division
      flash[:errors] = 'No division found with that id'
      redirect '/division/list'
    end

    @divisions = Division.order(:name).all.select { |d| d.teams_with_upcoming_games.length > 0 }
    @games = Game.where(teams: Team.where(division: @division)).where{ date >= Date.today }.order(:date)

    haml :'division/index'
  end
end
