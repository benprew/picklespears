#!/usr/bin/env ruby

require 'picklespears/test/unit'
require 'rack/test'

context 'spec_pickle-spears', PickleSpears::Test::Unit do

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before(:each) do
    player = nil
  end

  specify "null 2nd password works" do
    post '/player/create', 'email_address=test_user;password=test_pass'
    last_response.body.should match(/Passwords do not match/)
  end

  specify "post from sign in sets cookie" do
    Player.create_test(:email_address => 'test_user', :password => 'test_pass')
    post '/player/sign_in', 'email_address=test_user;password=test_pass'
    last_response.should include('Set-Cookie')
  end

  specify "post from sign in redirects to player hompage" do
    player = Player.create_test(:email_address => 'ben.prew@gmail.com', :password => 'test')
    post '/player/sign_in', 'email_address=ben.prew@gmail.com;password=test'
    last_response.location.should == '/player'
  end

  specify "error if unknown user tries to login" do
    post '/player/sign_in', 'email_address=foo'
    last_response.body.should match /Incorrect login/
  end

  specify "player page" do
    player = Player.create_test
    get '/player?id=' + player.id.to_s

    last_response.body.should match(/Teams/)
    last_response.body.should match(/Join New/i)
    last_response.body.should match(/Upcoming Games/i)
  end

  specify "show a default page" do
    get '/'
    last_response.ok?
  end

  specify 'can create player' do
    post '/player/create', 'name=bennie;email_address=test_com;phone_number=503_332_9719;birthdate=20080611;zipcode=97213;password=test;password2=test'

    last_response.headers.should include('Set-Cookie')
    last_response.headers['Location'].should match(/player\/join_team$/)

    player = Player.first(:name => 'bennie')
    player.email_address.should == 'test_com' 
  end

  specify 'attending status' do
    player = Player.create_test
    team = Team.create_test
    game = Game.create_test(:id => 4823)
    PlayersTeam.create_test(:player => player, :team => team)
    PlayersGame.create_test(:player => player, :game => game, :status => 'yes' )

    get '/player', :id => player.id
    assert_equal_ignoring_whitespace(last_response.body,
<<-HTML
    <div>
    Going: <strong>yes</strong>
    <a href="#" onclick="document.getElementById('status_4823').style.display = 'block'">[change]</a>
    <div id="status_4823" style="display:none">
      <strong>Going?</strong>
      <a href='#' onclick="set_attending_status('4823', 'yes', 'status_4823'); return false;">Yes</a>
      <a href='#' onclick="set_attending_status('4823', 'no', 'status_4823'); return false;">No</a>
      <a href='#' onclick="set_attending_status('4823', 'maybe', 'status_4823'); return false;">Maybe</a>
    </div>
    </div>
    HTML
    )
  end

  def assert_equal_ignoring_whitespace(is, should)
    should = should.gsub(/( |\n)+/m, '')
    is = is.gsub(/( |\n)+/m, '')

    should.should match Regexp.new(is)
  end

  specify 'select or edit your gender when you create your account' do
    player = Player.create_test(:gender => 'guy')
    player.gender.should == 'guy'
    get "/player?id=#{player.id}"

    last_response.body.should match(/gender/i)
  end

  specify 'todo' do

    print <<-TODO

      [ ] Join/Watch Multiple Teams
          [ ] Leave a team
      [ ] Communicate with all members of team
      [ ] Quickly see how many people are coming to the next game
          [ ] Get reminders about the next game, via email sms
      [ ] Manage a team
          [ ] Send game reminders
          [ ] See who has paid and how much
      [ ] Get contact info for players
          [ ] Allows player to say a little about themselves
          [ ] Post picture
              [ ] user image
                  post '/sorter' do
                    params[:data][:tempfile].readlines.sort
                  end
          [ ] Forgot username/password
      [ ] Find teams/players looking for players/teams

      [ ] can set manager for team


      [ ] for :collections => @things, see: http://github.com/cschneid/irclogger
    TODO

  end
end
