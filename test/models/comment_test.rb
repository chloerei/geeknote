require "test_helper"

class CommentTest < ActiveSupport::TestCase
  test "should query ancestors" do
    account = create(:user_account)
    post = create(:post, account: account)
    comment_one = create(:comment, commentable: post, account: account)
    comment_two = create(:comment, commentable: post, account: account, parent: comment_one)
    comment_three = create(:comment, commentable: post, account: account, parent: comment_two)
    comment_four = create(:comment, commentable: post, account: account, parent: comment_one)

    assert_equal [ comment_two, comment_one ], comment_three.ancestors
  end
end
