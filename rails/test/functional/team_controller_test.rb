require File.dirname(__FILE__) + '/../test_helper'
require 'team_controller'

# Re-raise errors caught by the controller.
class TeamController; def rescue_action(e) raise e end; end

class TeamControllerTest < Test::Unit::TestCase
  fixtures :teams

  def setup
    @controller = TeamController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = teams(:first).id
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

    assert_not_nil assigns(:teams)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:team)
    assert assigns(:team).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:team)
  end

  def test_create
    num_teams = Team.count

    post :create, :team => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_teams + 1, Team.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:team)
    assert assigns(:team).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Team.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Team.find(@first_id)
    }
  end
end
