class PickleSpears < Sinatra::Application
  # Meant to be called via ajax
  post '/game/:game_id/attending_status' do
    @user.set_attending_status_for_game(@game, params[:status])
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
      halt(422, "No division named #{params[:division]}")
    end

    home_team = Team.fuzzy_find(division, home, true)
    away_team = Team.fuzzy_find(division, away, true)

    unless home_team
      warn "No team named #{home}"
      halt(422, "No team named #{home}")
    end

    unless away_team
      warn "No team named #{away}"
      halt(422, "No team named #{away}")
    end

    game = Game.find_or_create(
      date: game_date,
      description: game_description
    )

    game.home_team = home_team
    game.away_team = away_team
    game.save
    game.to_s
  end
end
