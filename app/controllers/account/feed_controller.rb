class Account::FeedController < Account::BaseController
  def index
    @posts = scoped_posts.order(published_at: :desc).includes(:author_users).limit(20)

    respond_to do |format|
      format.atom
    end
  end

  private

  def scoped_posts
    if @account.user?
      @account.owner.author_posts.published.with_statuses(current_user)
    else
      @account.posts.published.with_statuses(current_user)
    end
  end
end
