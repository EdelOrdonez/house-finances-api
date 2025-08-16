require "test_helper"

class ExpenseTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @expense = @user.expenses.build(
      description: "Test expense",
      amount: 50.00,
      date: Date.current,
      category: "Food"
    )
  end

  test "should be valid" do
    assert @expense.valid?
  end

  test "description should be present" do
    @expense.description = "   "
    assert_not @expense.valid?
    assert_includes @expense.errors[:description], "can't be blank"
  end

  test "description should have minimum length" do
    @expense.description = "ab"
    assert_not @expense.valid?
    assert_includes @expense.errors[:description], "is too short (minimum is 3 characters)"
  end

  test "description should have maximum length" do
    @expense.description = "a" * 256
    assert_not @expense.valid?
    assert_includes @expense.errors[:description], "is too long (maximum is 255 characters)"
  end

  test "amount should be present" do
    @expense.amount = nil
    assert_not @expense.valid?
    assert_includes @expense.errors[:amount], "can't be blank"
  end

  test "amount should be positive" do
    @expense.amount = -10
    assert_not @expense.valid?
    assert_includes @expense.errors[:amount], "must be greater than 0"
  end

  test "amount should be zero" do
    @expense.amount = 0
    assert_not @expense.valid?
    assert_includes @expense.errors[:amount], "must be greater than 0"
  end

  test "date should be present" do
    @expense.date = nil
    assert_not @expense.valid?
    assert_includes @expense.errors[:date], "can't be blank"
  end

  test "category should be present" do
    @expense.category = "   "
    assert_not @expense.valid?
    assert_includes @expense.errors[:category], "can't be blank"
  end

  test "category should have maximum length" do
    @expense.category = "a" * 101
    assert_not @expense.valid?
    assert_includes @expense.errors[:category], "is too long (maximum is 100 characters)"
  end

  test "should belong to user" do
    @expense.user = nil
    assert_not @expense.valid?
    assert_includes @expense.errors[:user], "must exist"
  end

  test "formatted_amount should return correct format" do
    @expense.amount = 123.456
    assert_equal "123.46", @expense.formatted_amount
  end

  test "category_with_emoji should return correct emoji for food" do
    @expense.category = "Food"
    assert_equal "🍽️ Food", @expense.category_with_emoji
  end

  test "category_with_emoji should return correct emoji for transport" do
    @expense.category = "Transport"
    assert_equal "🚗 Transport", @expense.category_with_emoji
  end

  test "category_with_emoji should return category for unknown category" do
    @expense.category = "Unknown"
    assert_equal "Unknown", @expense.category_with_emoji
  end

  test "by_category scope should filter correctly" do
    @expense.save!
    filtered_expenses = @user.expenses.by_category("Food")
    assert_equal 1, filtered_expenses.count
    assert_equal "Food", filtered_expenses.first.category
  end

  test "by_date_range scope should filter correctly" do
    @expense.save!
    start_date = Date.current - 1.day
    end_date = Date.current + 1.day
    filtered_expenses = @user.expenses.by_date_range(start_date, end_date)
    assert_equal 1, filtered_expenses.count
  end

  test "recent scope should order by date desc" do
    @expense.save!
    older_expense = @user.expenses.create!(
      description: "Older expense",
      amount: 25.00,
      date: Date.current - 1.day,
      category: "Transport"
    )
    
    recent_expenses = @user.expenses.recent
    assert_equal @expense.id, recent_expenses.first.id
    assert_equal older_expense.id, recent_expenses.last.id
  end
end
