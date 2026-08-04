require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, email: "admin@example.com")
    sign_in @admin
  end

  test "should enqueue user deletion job and not destroy synchronously" do
    user = create(:user)

    assert_enqueued_with(job: UserDeletionJob, args: [ user ]) do
      delete admin_user_url(user)
    end

    assert_redirected_to admin_users_url
    assert User.exists?(user.id)
  end
end
