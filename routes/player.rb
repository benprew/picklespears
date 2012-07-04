class PickleSpears < Sinatra::Application
  get '/player' do
    @player_from_request = Player[params[:id] || session[:player_id]]
    haml :player
  end

  get '/player/logout' do
    session[:player_id] = nil
    redirect '/'
  end

  get '/player/create' do
    @errors = params[:errors]
    haml :player_create
  end

  get '/player/join_team' do
    @teams = []
    @teams = Team.filter(:name.like '%' + params[:team].upcase + '%').order(:name.asc).all if params[:team]
    haml :join_team
  end

  get '/player/edit' do
    haml :player_edit
  end

  post '/player/update' do
    @player ||= Player.new
    attrs = params
    attrs.delete(:update)
    attrs.delete('update')

    attrs.delete('openid') if @player.openid

    @player.set attrs

    if @player.valid?
      @player.save
      session[:player_id] = @player.id
      redirect to '/player'
    else
      @errors = @player.errors.map { |k, v| "#{k} #{v.join ''}" }.join "\n"
      partial :user_edit
    end
  end

  post '/player/remove_from_team' do
    team_id = params[:team_id]
    player_id = params[:player_id]

    url_params = { :team_id => team_id }
    if !PlayersTeam.filter(:player_id => player_id, :team_id => team_id).delete
      url_params[:errors] = "Could not remove player from team (p:#{player_id} t:#{team_id})"
    else
      url_params[:messages] = "You removed #{Player.first(:id => player_id).name} from the team"
    end


    redirect url_for '/team/edit', url_params
  end

  get '/player/attending_status_for_game' do
    game = Game[params[:game_id]]
    @status = params[:status]
    @player_from_request = Player[params[:player_id]]
    @player_from_request.set_attending_status_for_game(game, @status)
    message = haml :attending_status_for_game, :layout => false
    redirect url_for("/team", :messages => message, :team_id => game.team.id)
  end


end
