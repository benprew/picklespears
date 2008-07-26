#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__) + '/../sinatra/lib'

require 'sinatra'
require 'sinatra/test/spec'
require 'mocha'
require 'pickle-spears'

context 'PickleSpears' do
  before(:each) do
    require 'pickle-spears'
    player = nil
    @context = Sinatra::EventContext.new(stub("request"), stub("response", :body= => nil), stub("route params"))
  end

  specify "post from sign in sets cookie" do
    post_it '/player/sign_in', 'email=ben.prew@gmail.com'
    assert include?('Set-Cookie')
  end

  specify "post from sign in redirects to player hompage" do
    post_it '/player/sign_in', 'email_address=ben.prew@gmail.com;password=test'
    @response.location.should.equal '/player?id=12'
  end

  specify "error if unknown user tries to login" do
    post_it '/player/sign_in', 'email_address=foo'
    @response.body.should.match /Incorrect login/
  end

  specify "player page" do
    get_it '/player?id=12'

    @response.body.should.match /Teams/
    @response.body.should.match /Join a team/i 
    assert_match /Upcoming Games/i, @response.body
  end

  specify "show a default page" do
    get_it '/'
    assert ok?
  end

  specify 'can create player' do
    post_it '/player/create', 'name=bennie;email_address=test@test.com;phone_number=503.332.9719;birthdate=20080611;zipcode=97213'

    assert include?('Set-Cookie')
    assert_match /player/, @response.headers['Location'], 'redirect to player homepage, no errors'

    player = Player.first(:name => 'bennie')
    player.email_address.should.equal 'test@test.com' 
    player.destroy
  end

  specify 'attending_status' do
    pg = PlayersTeam.first
    assert_equal_ignoring_whitespace(@context.status_for_game(pg.player, pg.team.games.get(4823)), <<-HTML
    Your status: <strong>yes</strong>
    <a href="#" onclick="document.getElementById('status_4823').style.display = 'block'">[change]</a>
    <div id="status_4823" style="display:none">
      <strong>Attending?</strong>
      <a href='#' onclick="set_attending_status('4823', 'yes', 'status_4823'); return false;">Yes</a>
      <a href='#' onclick="set_attending_status('4823', 'no', 'status_4823'); return false;">No</a>
      <a href='#' onclick="set_attending_status('4823', 'maybe', 'status_4823'); return false;">Maybe</a>
    </div>
    HTML
    )
  end

  def assert_equal_ignoring_whitespace(should, is)
    should = should.gsub(/( |\n)+/m, '')
    is = is.gsub(/( |\n)+/m, '')

    assert_equal(should, is)
  end

  specify 'let you pick your gender' do
  end

  specify 'game reminders' do
  end

  specify 'can set manager for team' do
  end
end
