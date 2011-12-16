class PickleSpears < Sinatra::Application
  get '/division/schedule_games' do
    haml :schedule_games
  end
end
