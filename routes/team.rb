class PickleSpears < Sinatra::Application
  include Icalendar

  before '/team/*' do
    @team = Team[params[:id]]
  end

  # Meant to be an ajax call
  post '/team/join' do
    @user.add_team(Team[params[:id]])
    'Joined!'
  end

  post '/team/update' do
    team = Team[params[:id]]
    team.name = params[:name]
    team.division_id = params[:division_id]
    team.save

    flash[:messages] = 'Team updated!'

    redirect uri_for(team)
  end

  post '/team/add_player' do
    player = Player.find_or_create(:email_address => params[:email]) { |p| p.name = params[:name] }

    if player && @team
      if @team.players.include?(player)
        flash[:messages] = "Player \"#{player.name}\" already on roster, not re-adding"
      else
        @team.add_player(player)
        flash[:messages] = "Player \"#{player.name}\" added to team."
      end
    else
      halt 400
    end

    # TODO: send email to user to register
    redirect uri_for(@team, 'edit')
  end
end
