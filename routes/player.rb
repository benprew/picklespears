class PickleSpears < Sinatra::Application
  get '/player' do
    @player_from_request = Player[params[:id] || session[:player_id]]
    haml :player
  end

  get '/player/login' do
    haml :login
  end

  post '/player/login' do
    if player = Player.authenticate(params[:email_address], params[:password])
      session[:player_id] = player.id
      player.update(last_login: Date.today)
      redirect '/player'
    else
      flash[:errors] = 'Incorrect username or password'
      redirect '/player/login'
    end
  end

  get '/player/logout' do
    session.delete(:player_id)
    flash[:messages] = "You have been logged out"
    redirect '/'
  end

  get '/player/signup' do
    haml :player_signup
  end

  post '/player/signup' do
    params['player'][:name] = params['player'][:email_address]
    @player = Player.new(params['player'])
    if @player.valid?
      @player.save
      session[:player_id] = @player.id
      flash[:success] = "Account created."
      redirect '/player/edit'
    else
      flash[:errors] = "There were some problems creating your account: #{@player.errors}."
      redirect url_for('/player/signup?', params['player'])
    end
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

    if !PlayersTeam.filter(:player_id => player_id, :team_id => team_id).delete
      flash[:errors] = "Could not remove player from team (p:#{player_id} t:#{team_id})"
    else
      flash[:messages] = "You removed #{Player.first(:id => player_id).name} from the team"
    end

    redirect url_for '/team/edit', team_id: team_id
  end

  get '/player/attending_status_for_game' do
    game = Game[params[:game_id]]
    @status = params[:status]
    @player_from_request = Player[params[:player_id]]
    @player_from_request.set_attending_status_for_game(game, @status)
    flash[:messages] = haml :attending_status_for_game, :layout => false
    redirect url_for("/team", :team_id => game.team.id)
  end
end
