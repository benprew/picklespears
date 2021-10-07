# frozen_string_literal: true

class PickleSpears < Sinatra::Application
  post '/player/login' do
    if (user = Player.authenticate(params[:email_address], params[:password]))
      session[:player_id] = user.id
      user.update(last_login: Date.today)
      redirect uri_for(user)
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

  post '/player/signup' do
    params['player'][:name] = params['player'][:email_address]
    @player = Player.new(params['player'])
    if @player.valid?
      @player.save
      session[:player_id] = @player.id
      flash[:success] = 'Account created'
      redirect uri_for(@player, 'edit')
    else
      flash[:errors] = "Unable to create your account: #{@player.errors}"
      redirect uri_for(@player, 'signup', args: params['player'])
    end
  end

  post '/player/update' do
    @player = Player[params[:id]]
    unless @user
      flash[:errors] = 'Must be logged in to edit your profile'
      redirect '/player/login'
    end

    if @user != @player
      flash[:errors] = 'You are not allowed to edit this profile'
      redirect uri_for(@player)
    end
    attrs = params
    attrs.delete(:update)
    attrs.delete('update')
    attrs.delete('id')

    attrs.delete('openid') if @player.openid

    @player.set attrs

    if @player.valid?
      @player.save
      session[:player_id] = @player.id
      redirect uri_for(@player)
    else
      flash[:errors] = @player.errors.map { |k, v| "#{k} #{v.join ''}" }.join "\n"
      redirect uri_for(@player, 'edit')
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

    redirect uri_for(Team[team_id], 'edit')
  end

  get '/player/attending_status_for_game' do
    game = Game[params[:game_id]]
    status = params[:status]
    player = Player[params[:player_id]]

    halt 400 unless game && player

    player.set_attending_status_for_game(game, status)
    flash[:messages] = partial 'attending_status_for_game', locals: { status: status }
    redirect uri_for(game.team_player_plays_on(player))
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
      html_body: partial(:password_reset_email)
    )
    slim 'player/password_reset_sent'.to_sym
  end

  get '/player/reset/:reset_sha' do
    @sha = params[:reset_sha]
    player = Player.first(password_reset_hash: @sha)

    if player && Date.today <= player.password_reset_expires_on
      session[:player_id] = player.id
      slim 'player/reset'.to_sym
    else
      flash[:errors] = 'Password reset link expired or invalid'
      redirect '/player/login'
    end
  end

  post '/player/reset/:reset_sha' do
    @user.set(params['player'].select do |k, _v|
      %i[password password_confirmation].include?(k.to_sym)
    end)

    if @user.valid?
      @user.password_reset_expires_on = nil
      @user.password_reset_hash = nil
      @user.save
      flash[:success] = 'Password reset successfully'
      redirect '/player/login'
    else
      flash[:errors] = "Passwords don't match"
      redirect "/player/reset/#{params[:reset_sha]}"
    end
  end
end
