class PickleSpears < Sinatra::Application
  before '/game/:game_id/*' do
    begin
      @game = Game[params[:game_id]]
    rescue
      halt 404
    end
    halt 404 unless @game
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
end
