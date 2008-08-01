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

  specify "post from sign in sets cookie" do
    post_it '/player/sign_in', 'email=ben.prew@gmail.com'
    assert include?('Set-Cookie')
  end

  specify "post from sign in redirects to player hompage" do
    player = Player.create_test(:email_address => 'ben.prew@gmail.com', :password => 'test')
    post_it '/player/sign_in', 'email_address=ben.prew@gmail.com;password=test'
    @response.location.should.equal '/player?id=' + player.id.to_s
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
    post_it '/player/create', 'name=bennie;email_address=test@test.com;phone_number=503.332.9719;birthdate=20080611;zipcode=97213;password=test;password2=test'

    assert include?('Set-Cookie')
    assert_match /player$/, @response.headers['Location'], 'redirect to player homepage, no errors'

    player = Player.first(:name => 'bennie')
    player.email_address.should.equal 'test@test.com' 
    player.destroy
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

      [ ] get email reminders working... see http://irclogger.com/sinatra/2008-07-25
          email :to => "godfoca@gmail.com", :from => "godfoca@gmail.com", :subject => "cuack 2", :text => "blah" end 
          http://github.com/foca/sinatra-mailer/tree/master 

      [ ] can set manager for team

      [ ] can edit user information

      [ ] for :collections => @things, see: http://github.com/cschneid/irclogger
    TODO

  end
end
