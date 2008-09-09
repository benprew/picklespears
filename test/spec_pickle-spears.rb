#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__) + '/../sinatra/lib'

require 'sinatra'
require 'sinatra/test/spec'
require 'pickle-spears'
require 'mocha'
require 'picklespears/test/unit'

context 'spec_pickle-spears', PickleSpears::Test::Unit do
  before(:each) do
    
    require 'pickle-spears'
    player = nil
    @context = Sinatra::EventContext.new(stub("request"), stub("response", :body= => nil), stub("route params"))
  end

  specify "null 2nd password works" do
    post_it '/player/create', 'email_address=test_user;password=test_pass'
    @response.body.should.match 'Passwords do not match'
  end

  specify "post from sign in sets cookie" do
    Player.create_test(:email_address => 'test_user', :password => 'test_pass')
    post_it '/player/sign_in', 'email_address=test_user;password=test_pass'
    assert include?('Set-Cookie')
  end

  specify "post from sign in redirects to player hompage" do
    player = Player.create_test(:email_address => 'ben.prew@gmail.com', :password => 'test')
    post_it '/player/sign_in', 'email_address=ben.prew@gmail.com;password=test'
    @response.location.should.equal '/player'
  end

  specify "error if unknown user tries to login" do
    post_it '/player/sign_in', 'email_address=foo'
    @response.body.should.match /Incorrect login/
  end

  specify "player page" do
    player = Player.create_test
    get_it '/player?id=' + player.id.to_s

    @response.body.should.match /Teams/
    @response.body.should.match /Join New/i 
    assert_match /Upcoming Games/i, @response.body
  end

  specify "show a default page" do
    get_it '/'
    assert ok?
  end

  specify 'can create player' do
    post_it '/player/create', 'name=bennie;email_address=test_com;phone_number=503_332_9719;birthdate=20080611;zipcode=97213;password=test;password2=test'

    assert include?('Set-Cookie')
    assert_match /player\/join_team$/, @response.headers['Location'], 'redirect to player homepage, no errors'

    player = Player.first(:name => 'bennie')
    player.email_address.should.equal 'test_com' 
  end

  specify 'attending status' do
    player = Player.create_test
    team = Team.create_test
    game = Game.create_test(:id => 4823)
    PlayersTeam.create_test(:player => player, :team => team)
    PlayersGame.create_test(:player => player, :game => game, :status => 'yes' )

    assert_equal_ignoring_whitespace(@context.status_for_game(player, game), <<-HTML
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

    assert_equal(should, is)
  end

  specify 'select/edit your gender when you create your account' do
    player = Player.create_test(:gender => 'guy')
    player.gender.should.equal 'guy'
    get_it "/player?id=#{player.id}"

    @response.body.should.match /gender/i
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
