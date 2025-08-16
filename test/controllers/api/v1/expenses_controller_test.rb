require "test_helper"

class Api::V1::ExpensesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  
  setup do
    @user = users(:one)
    @expense = expenses(:one)
    @user.update!(email: 'test@example.com', password: 'password123')
  end
  
  test "should get index when authenticated" do
    sign_in @user
    get api_v1_expenses_url, as: :json
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal 'success', json_response['status']
    assert_includes json_response['data'], 'expenses'
  end
  
  test "should not get index when not authenticated" do
    get api_v1_expenses_url, as: :json
    assert_response :unauthorized
  end
  
  test "should create expense when authenticated" do
    sign_in @user
    
    assert_difference('Expense.count') do
      post api_v1_expenses_url, params: {
        expense: {
          description: 'Test expense',
          amount: 50.00,
          date: Date.current,
          category: 'Food'
        }
      }, as: :json
    end
    
    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal 'success', json_response['status']
    assert_equal 'Expense created successfully', json_response['message']
  end
  
  test "should not create expense with invalid params" do
    sign_in @user
    
    assert_no_difference('Expense.count') do
      post api_v1_expenses_url, params: {
        expense: {
          description: '',
          amount: -10,
          date: nil,
          category: ''
        }
      }, as: :json
    end
    
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_equal 'error', json_response['status']
    assert_includes json_response['errors'], "Description can't be blank"
  end
  
  test "should show expense when authenticated" do
    sign_in @user
    get api_v1_expense_url(@expense), as: :json
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal 'success', json_response['status']
    assert_equal @expense.id, json_response['data']['id']
  end
  
  test "should update expense when authenticated" do
    sign_in @user
    
    patch api_v1_expense_url(@expense), params: {
      expense: { description: 'Updated description' }
    }, as: :json
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 'success', json_response['status']
    assert_equal 'Updated description', json_response['data']['description']
  end
  
  test "should destroy expense when authenticated" do
    sign_in @user
    
    assert_difference('Expense.count', -1) do
      delete api_v1_expense_url(@expense), as: :json
    end
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 'success', json_response['status']
    assert_equal 'Expense deleted successfully', json_response['message']
  end
  
  test "should get summary when authenticated" do
    sign_in @user
    get summary_api_v1_expenses_url, as: :json
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal 'success', json_response['status']
    assert_includes json_response['data'], 'total_expenses'
  end
  
  test "should get categories when authenticated" do
    sign_in @user
    get categories_api_v1_expenses_url, as: :json
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal 'success', json_response['status']
    assert_includes json_response['data'], 'Food'
  end
end
