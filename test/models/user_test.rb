require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @user.update!(email: 'test@example.com', password: 'password123')
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "email should be present" do
    @user.email = "   "
    assert_not @user.valid?
    assert_includes @user.errors[:email], "can't be blank"
  end

  test "email should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:email], "has already been taken"
  end

  test "email should be valid format" do
    valid_emails = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    valid_emails.each do |valid_email|
      @user.email = valid_email
      assert @user.valid?, "#{valid_email.inspect} should be valid"
    end
  end

  test "email should be invalid format" do
    invalid_emails = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]
    invalid_emails.each do |invalid_email|
      @user.email = invalid_email
      assert_not @user.valid?, "#{invalid_email.inspect} should be invalid"
    end
  end

  test "password should be present on create" do
    new_user = User.new(email: 'new@example.com')
    assert_not new_user.valid?
    assert_includes new_user.errors[:password], "can't be blank"
  end

  test "password should have minimum length on create" do
    new_user = User.new(
      email: 'new@example.com',
      password: '12345',
      password_confirmation: '12345'
    )
    assert_not new_user.valid?
    assert_includes new_user.errors[:password], "is too short (minimum is 6 characters)"
  end

  test "should have many expenses" do
    assert_respond_to @user, :expenses
  end

  test "expenses should be destroyed when user is destroyed" do
    @user.expenses.create!(
      description: "Test expense",
      amount: 50.00,
      date: Date.current,
      category: "Food"
    )
    
    assert_difference 'Expense.count', -1 do
      @user.destroy
    end
  end

  test "total_expenses should return correct sum" do
    @user.expenses.destroy_all
    @user.expenses.create!(
      description: "Expense 1",
      amount: 100.00,
      date: Date.current,
      category: "Food"
    )
    @user.expenses.create!(
      description: "Expense 2",
      amount: 50.00,
      date: Date.current,
      category: "Transport"
    )
    
    assert_equal 150.00, @user.total_expenses
  end

  test "expenses_by_category should return correct grouping" do
    @user.expenses.destroy_all
    @user.expenses.create!(
      description: "Food expense",
      amount: 100.00,
      date: Date.current,
      category: "Food"
    )
    @user.expenses.create!(
      description: "Transport expense",
      amount: 50.00,
      date: Date.current,
      category: "Transport"
    )
    @user.expenses.create!(
      description: "Another food expense",
      amount: 75.00,
      date: Date.current,
      category: "Food"
    )
    
    expected = { "Food" => 175.00, "Transport" => 50.00 }
    assert_equal expected, @user.expenses_by_category
  end

  test "monthly_expenses should return correct sum for current month" do
    @user.expenses.destroy_all
    @user.expenses.create!(
      description: "This month expense",
      amount: 100.00,
      date: Date.current,
      category: "Food"
    )
    @user.expenses.create!(
      description: "Last month expense",
      amount: 50.00,
      date: Date.current - 1.month,
      category: "Transport"
    )
    
    assert_equal 100.00, @user.monthly_expenses
  end

  test "monthly_expenses should return correct sum for specific month" do
    @user.expenses.destroy_all
    specific_month = Date.current - 2.months
    @user.expenses.create!(
      description: "Specific month expense",
      amount: 200.00,
      date: specific_month,
      category: "Food"
    )
    
    assert_equal 200.00, @user.monthly_expenses(specific_month.year, specific_month.month)
  end

  test "expenses_summary should return complete summary" do
    @user.expenses.destroy_all
    @user.expenses.create!(
      description: "Test expense",
      amount: 100.00,
      date: Date.current,
      category: "Food"
    )
    
    summary = @user.expenses_summary
    
    assert_includes summary, :total_expenses
    assert_includes summary, :total_count
    assert_includes summary, :by_category
    assert_includes summary, :this_month
    
    assert_equal 100.00, summary[:total_expenses]
    assert_equal 1, summary[:total_count]
    assert_equal({ "Food" => 100.00 }, summary[:by_category])
    assert_equal 100.00, summary[:this_month]
  end

  test "active scope should filter users with passwords" do
    assert_includes User.active, @user
  end
end
