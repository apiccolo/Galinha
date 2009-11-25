require 'test_helper'

class DescontosControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:descontos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create desconto" do
    assert_difference('Desconto.count') do
      post :create, :desconto => { }
    end

    assert_redirected_to desconto_path(assigns(:desconto))
  end

  test "should show desconto" do
    get :show, :id => descontos(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => descontos(:one).to_param
    assert_response :success
  end

  test "should update desconto" do
    put :update, :id => descontos(:one).to_param, :desconto => { }
    assert_redirected_to desconto_path(assigns(:desconto))
  end

  test "should destroy desconto" do
    assert_difference('Desconto.count', -1) do
      delete :destroy, :id => descontos(:one).to_param
    end

    assert_redirected_to descontos_path
  end
end
