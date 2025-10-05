class Account::Posts::ViewsController < Account::Posts::BaseController
  def create
    ahoy.track "post_view", account_id: @account.id, post_id: @post.id
    Post.increment_counter(:views_count, @post.id)
    head :ok
  end
end
