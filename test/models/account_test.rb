require "test_helper"

class AccountTest < ActiveSupport::TestCase
  test "should validate name exclusion" do
    account = build(:account)

    account.name = "notspecial"
    account.valid?
    assert_not account.errors.added? :name, :exclusion

    account.name = "admin"
    account.valid?
    assert account.errors.added? :name, :exclusion

    account.name = "Admin"
    account.valid?
    assert account.errors.added? :name, :exclusion
  end
end
