require "test_helper"

class AccountTest < ActiveSupport::TestCase
  test "should validate name exclusion" do
    account = build(:account)

    account.name = 'notspecial'
    account.valid?
    assert_not account.errors.added? :name, :exclusion

    account.name = 'admin'
    account.valid?
    assert account.errors.added? :name, :exclusion

    account.name = 'Admin'
    account.valid?
    assert account.errors.added? :name, :exclusion
  end

  test "should validate feed_url is valid Url" do
    account = create(:user_account)
    account.update(feed_url: "https://example.com")
    assert account.valid?

    account.update(feed_url: "javascript:alert('https://example.com')")
    assert_not account.valid?
    assert account.errors.added?(:feed_url, :invalid_url)
  end
end
