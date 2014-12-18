class PickleSpears < Sinatra::Application
  before %r{/player/(\d+)/*} do |player_id|
    begin
      @player_from_request = Player[player_id]
    rescue Sequel::DatabaseError
      halt 404
    end
    halt 404 unless @player_from_request
  end

  get '/player' do
    @player_from_request = Player[params[:id] || session[:player_id]]
    haml 'player/index'.to_sym
  end

  get '/player/login' do
    haml 'player/login'.to_sym
  end

  post '/player/login' do
    if player = Player.authenticate(params[:email_address], params[:password])
      session[:player_id] = player.id
      @player = player
      @player.update(last_login: Date.today)
      if is_league_manager?
        redirect '/league/manage'
      else
        redirect '/player'
      end
    else
      flash[:errors] = 'Incorrect username or password'
      redirect '/player/login'
    end
  end

  get '/player/logout' do
    session.delete(:player_id)
    flash[:messages] = 'You have been logged out'
    redirect '/'
  end

  get '/player/signup' do
    haml 'player/signup'.to_sym
  end

  post '/player/signup' do
    params['player'][:name] = params['player'][:email_address]
    @player = Player.new(params['player'])
    if @player.valid?
      @player.save
      session[:player_id] = @player.id
      flash[:success] = 'Account created'
      redirect "/player/#{@player.id}/edit"
    else
      flash[:errors] = "Unable to create your account: #{@player.errors}"
      redirect url_for('/player/signup?', params['player'])
    end
  end

  get '/player/join_team' do
    @teams = []
    if params[:team]
      @teams = Team.filter(Sequel.ilike(:name, "%#{params[:team]}%"))
        .order(Sequel.asc(:name))
        .all
    end
    haml 'player/join_team'.to_sym
  end

  get '/player/:player_id/edit' do
    halt 403 unless @player == @player_from_request
    @editable = true
    @p = @player_from_request
    haml 'player/index'.to_sym
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

    if !PlayersTeam.filter(player_id: player_id, team_id: team_id).delete
      flash[:errors] =
        "Couldn't remove player from team (p:#{player_id} t:#{team_id})"
    else
      flash[:messages] = "You removed #{Player[player_id].name} from the team"
    end

    redirect url_for '/team/edit', team_id: team_id
  end

  get '/player/attending_status_for_game' do
    game = Game[params[:game_id]]
    @status = params[:status]
    @player_from_request = Player[params[:player_id]]

    halt 400 unless game && @player_from_request

    @player_from_request.set_attending_status_for_game(game, @status)
    flash[:messages] = partial 'attending_status_for_game'
    redirect url_for('/team', team_id: game.team_player_plays_on(@player_from_request).id)
  end

  get '/player/forgot_password' do
    haml 'player/forgot_password'.to_sym
  end

  post '/player/forgot_password' do
    @email_address = params[:email_address]
    @player = Player.first(email_address: @email_address)
    unless @player
      flash[:errors] = "Email address #{@email_address} not found"
      redirect '/player/forgot_password'
      return
    end
    @player.password_reset_hash = Digest::SHA2.new.update(@player.to_s + Time.now.to_s).to_s
    @player.password_reset_expires_on = Date.today + 2
    @player.save

    send_email(
      to: @email_address,
      subject: 'Reset your password for Teamvite.com',
      html_body: partial(:password_reset_email),
    )
    haml 'player/password_reset_sent'.to_sym
  end

  get "/player/reset/:reset_sha" do
    @sha = params[:reset_sha]
    player = Player.first(password_reset_hash: @sha)

    if player && Date.today <= player.password_reset_expires_on
      session[:player_id] = player.id
      haml 'player/reset'.to_sym
    else
      flash[:errors] = 'Password reset link expired or invalid'
      redirect '/player/login'
    end
  end

  post '/player/reset/:reset_sha' do
    @player.set(params['player'].select do |k, v|
      [:password, :password_confirmation].include?(k.to_sym)
    end)

    if @player.valid?
      @player.password_reset_expires_on = nil
      @player.password_reset_hash = nil
      @player.save
      flash[:success] = 'Password reset successfully'
      redirect '/player/login'
    else
      flash[:errors] = "Passwords don't match"
      redirect "/player/reset/#{params[:reset_sha]}"
    end
  end
end
