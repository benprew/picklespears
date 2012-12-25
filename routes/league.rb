class PickleSpears < Sinatra::Application

  before '/league/*' do
    redirect '/' unless is_league_manager?
  end

  get '/league/manage' do
    @games = []
    date = params[:date] ? Date.parse(params[:date]) : Date.today

    if date
      @games = Game.where( id: DB[%q{SELECT max(g.id) from players p
        INNER JOIN league_managers lm ON (p.id = lm.player_id)
        INNER JOIN divisions d ON (d.league_id = lm.league_id)
        INNER JOIN teams t on (t.division_id = d.id)
        INNER JOIN teams_games tg on (t.id = tg.team_id)
        INNER JOIN games g on (g.id = tg.game_id)
        WHERE g.date between ? AND ? GROUP BY g.description }, date, date + 1].all.map { |i| i.values }.flatten).order( :date )
    else
      flash[:errors] = "Did not understand date: #{params[:date]}"
    end

    haml 'league/manage'.to_sym, locals: { date: date }
  end

  get '/league/game_report/:game_id.pdf' do
    game = Game[params[:game_id]]

    unless game
      flash[:errors] = "Invalid game id: #{params[:game_id]}"
      redirect '/league/manage'
    end

    (home_team, away_team) = game.description.split(/\s+vs\s+/i)

    pdffile = "public/#{params[:game_id]}.pdf"
    Prawn::Document.generate(pdffile, template: 'pdfs/PI_template.pdf') do
      text_box game.date.strftime(DATE_FORMAT), at: [152, 679]
      text_box game.division.name, at: [152, 650]

      text_box home_team, at: [22, 525], size: 16
      text_box away_team, at: [292, 525], size: 16
    end

    send_file pdffile
  end

  helpers do
    def is_league_manager?
      @player && @player.is_league_manager?
    end
  end
end
