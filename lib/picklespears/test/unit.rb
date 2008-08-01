require 'test/unit'

# needed so I can call my class PS::Test::Unit -- below
class PickleSpears::Test
end

class PickleSpears::Test::Unit < Test::Unit::TestCase

  def setup
    repository.adapter.execute('begin transaction')
  end

  def teardown
    repository.adapter.execute('rollback')
  end

  # needed for a "default" test?
  def test_foo
  end
end