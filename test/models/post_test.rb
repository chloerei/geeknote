require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "should set published at" do
    post = create(:post, status: :draft)
    assert_nil post.published_at
    post.published!
    assert_not_nil post.published_at
  end

  test "should restricted post" do
    post = create(:post, status: 'published')
    post.restricted!
    assert post.restricted?
    assert post.draft?

    post.remove_restricted
    assert_not post.restricted?
  end

  test "should create revision" do
    post = create(:post, title: 'title')
    user_1 = create(:user)
    user_2 = create(:user)

    assert_difference "post.revisions.count" do
      post.save_revision(status: 'draft', user: user_1)
    end
    assert_equal 'title', post.revisions.last.title

    travel 30.seconds do
      post.update(title: 'change_by_user_1')
      assert_no_difference "post.revisions.count" do
        post.save_revision(status: 'draft', user: user_1)
      end
      assert_equal 'change_by_user_1', post.revisions.last.title
    end

    travel 4.minutes do
      post.update(title: 'change_by_1_minte_later')
      assert_difference "post.revisions.count" do
        post.save_revision(status: 'draft', user: user_1)
      end
      assert_equal 'change_by_1_minte_later', post.revisions.last.title
    end

    travel 30.seconds do
      post.update(title: 'change_by_user_2')
      assert_difference "post.revisions.count" do
        post.save_revision(status: 'draft', user: user_2)
      end
      assert_equal 'change_by_user_2', post.revisions.last.title

      assert_difference "post.revisions.count" do
        post.save_revision(status: 'published', user: user_2)
      end
      assert_equal 'published', post.revisions.last.status
    end
  end
end
