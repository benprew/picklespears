require File.dirname(__FILE__) + '/../test_helper'
require 'division_controller'

# Re-raise errors caught by the controller.
class DivisionController; def rescue_action(e) raise e end; end

class DivisionControllerTest < Test::Unit::TestCase
  fixtures :divisions

  def setup
    @controller = DivisionController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = divisions(:first).id
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

    assert_not_nil assigns(:divisions)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:division)
    assert assigns(:division).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:division)
  end

  def test_create
    num_divisions = Division.count

    post :create, :division => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_divisions + 1, Division.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:division)
    assert assigns(:division).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Division.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Division.find(@first_id)
    }
  end
end
