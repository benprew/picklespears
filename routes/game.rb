class PickleSpears < Sinatra::Application
  before '/game/:game_id/*' do
    begin
      @game = Game[params[:game_id]]
    rescue
      halt 404, 'game not found'
    end
    halt(404, 'game not found') unless @game
  end

  get '/game/:game_id' do
    redirect "/game/#{params[:game_id]}/"
  end

  get '/game/:game_id/' do
    @team_games = [@game.teams.first, @game]
    haml :'game/index'
  end

  # Meant to be called via ajax
  get '/game/:game_id/attending_status' do
    @player.set_attending_status_for_game(@game, params[:status])
    "<p>Status #{params[:status]} recorded</p>"
  end

  post '/game' do
    game_date = Time.parse params[:date]
    game_description = params[:description]
    home = params[:home_team]
    away = params[:away_team]
    division = Division.first(name: params[:division])

    unless division
      warn "No division named #{params[:division]}"
      halt(404, "No division named #{params[:division]}")
    end

    home_team = Team.find(division: division, name: home)
    away_team = Team.find(division: division, name: away)

    unless home_team
      warn "No team named #{home}"
      halt(404, "No team named #{home}")
    end

    unless away_team
      warn "No team named #{away}"
      halt(404, "No team named #{away}")
    end

    game = Game.find_or_create(
      date: game_date,
      description: game_description)

    game.home_team = home_team
    game.away_team = away_team
    game.save
    game.to_s
  end
end
