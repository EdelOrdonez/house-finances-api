require "test_helper"

class JwtDenylistTest < ActiveSupport::TestCase
  def setup
    @jwt_denylist = JwtDenylist.new(
      jti: "test_jti_#{SecureRandom.hex(10)}",
      exp: 1.hour.from_now
    )
  end

  test "should be valid" do
    assert @jwt_denylist.valid?
  end

  test "jti should be present" do
    @jwt_denylist.jti = "   "
    assert_not @jwt_denylist.valid?
    assert_includes @jwt_denylist.errors[:jti], "can't be blank"
  end

  test "jti should be unique" do
    @jwt_denylist.save!
    duplicate = @jwt_denylist.dup
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:jti], "has already been taken"
  end

  test "exp should be present" do
    @jwt_denylist.exp = nil
    assert_not @jwt_denylist.valid?
    assert_includes @jwt_denylist.errors[:exp], "can't be blank"
  end

  test "expired? should return true for expired token" do
    @jwt_denylist.exp = 1.hour.ago
    assert @jwt_denylist.expired?
  end

  test "expired? should return false for active token" do
    @jwt_denylist.exp = 1.hour.from_now
    assert_not @jwt_denylist.expired?
  end

  test "active? should return true for active token" do
    @jwt_denylist.exp = 1.hour.from_now
    assert @jwt_denylist.active?
  end

  test "active? should return false for expired token" do
    @jwt_denylist.exp = 1.hour.ago
    assert_not @jwt_denylist.active?
  end

  test "expired scope should filter expired tokens" do
    @jwt_denylist.save!
    expired_token = JwtDenylist.create!(
      jti: "expired_jti_#{SecureRandom.hex(10)}",
      exp: 1.hour.ago
    )
    
    expired_tokens = JwtDenylist.expired
    assert_includes expired_tokens, expired_token
    assert_not_includes expired_tokens, @jwt_denylist
  end

  test "active scope should filter active tokens" do
    @jwt_denylist.save!
    expired_token = JwtDenylist.create!(
      jti: "expired_jti_#{SecureRandom::hex(10)}",
      exp: 1.hour.ago
    )
    
    active_tokens = JwtDenylist.active
    assert_includes active_tokens, @jwt_denylist
    assert_not_includes active_tokens, expired_token
  end

  test "cleanup_expired should remove expired tokens" do
    @jwt_denylist.save!
    expired_token = JwtDenylist.create!(
      jti: "expired_jti_#{SecureRandom.hex(10)}",
      exp: 1.hour.ago
    )
    
    assert_difference 'JwtDenylist.count', -1 do
      JwtDenylist.cleanup_expired
    end
    
    assert_not_includes JwtDenylist.all, expired_token
    assert_includes JwtDenylist.all, @jwt_denylist
  end

  test "should use correct table name" do
    assert_equal "jwt_denylists", JwtDenylist.table_name
  end

  test "should include Devise JWT revocation strategy" do
    assert JwtDenylist.included_modules.include?(Devise::JWT::RevocationStrategies::Denylist)
  end
end
