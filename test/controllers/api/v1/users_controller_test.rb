require "test_helper"

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  
  setup do
    @user = users(:one)
    @user.update!(email: 'test@example.com', password: 'password123')
  end
  
  test "should get profile when authenticated" do
    sign_in @user
    get profile_api_v1_users_url, as: :json
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal 'success', json_response['status']
    assert_includes json_response['data'], 'user'
    assert_includes json_response['data'], 'expenses_summary'
  end
  
  test "should not get profile when not authenticated" do
    get profile_api_v1_users_url, as: :json
    assert_response :unauthorized
  end
  
  test "profile should include user information" do
    sign_in @user
    get profile_api_v1_users_url, as: :json
    assert_response :success
    
    json_response = JSON.parse(response.body)
    user_data = json_response['data']['user']
    
    assert_equal @user.id, user_data['id']
    assert_equal @user.email, user_data['email']
    assert_includes user_data, 'created_at'
  end
  
  test "profile should include expenses summary" do
    sign_in @user
    get profile_api_v1_users_url, as: :json
    assert_response :success
    
    json_response = JSON.parse(response.body)
    summary_data = json_response['data']['expenses_summary']
    
    assert_includes summary_data, 'total_expenses'
    assert_includes summary_data, 'total_count'
    assert_includes summary_data, 'by_category'
    assert_includes summary_data, 'this_month'
  end
end
