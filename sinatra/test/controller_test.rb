#!/usr/bin/env ruby

require 'rubygems'
require 'controller'
require 'sinatra/test/unit'

class PickleSpearsControllerTest < Test::Unit::TestCase
  def test_homepage
    get_it '/'
    m = /<title>[^<]+<\/title>/.match(@response.body)
    assert_equal '<title>Pickle Spears - homepage</title>', m[0]
  end

  def test_browse
    get_it '/browse?league=Women'
    m = /<title>[^<]+<\/title>/.match(@response.body)
    assert_equal '<title>Pickle Spears - browse teams</title>', @response.body
  end

end

