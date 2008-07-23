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
  end

  specify "post from sign in sets cookie" do
    post_it '/player/sign_in', 'email=ben.prew@gmail.com'
    assert include?('Set-Cookie')
  end

  specify "post from sign in redirects to player hompage" do
    post_it '/player/sign_in', 'email_address=ben.prew@gmail.com;password=test'
    assert_equal '/player?id=12', @response.location
  end

  specify "error if unknown user tries to login" do
    post_it '/player/sign_in', 'email_address=foo'
    assert_match /Incorrect login/, @response.body
  end

  specify "player page" do
    get_it '/player?id=12'

    assert_match /Teams/, @response.body
    assert_match /Join a team/i, @response.body
    assert_match /Upcoming Games/i, @response.body
  end

  specify "show a default page" do
    get_it '/'
    assert ok?
  end

  specify 'can create player' do
    post_it '/player/create', 'name=bennie;email_address=test@test.com;phone_number=503.332.9719;birthdate=20080611;zipcode=97213'

    assert include?('Set-Cookie')
    assert_match /player\?errors=$/, @response.headers['Location'], 'redirect to player homepage, no errors'

    assert_equal 'test@test.com', Player.first.email_address
  end
end
