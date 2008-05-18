require File.dirname(__FILE__) + '/../test_helper'
require 'game_controller'

# Re-raise errors caught by the controller.
class GameController; def rescue_action(e) raise e end; end

class GameControllerTest < Test::Unit::TestCase
  fixtures :games

  def setup
    @controller = GameController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = games(:first).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:games)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:game)
    assert assigns(:game).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:game)
  end

  def test_create
    num_games = Game.count

    post :create, :game => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_games + 1, Game.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:game)
    assert assigns(:game).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Game.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Game.find(@first_id)
    }
  end
end
