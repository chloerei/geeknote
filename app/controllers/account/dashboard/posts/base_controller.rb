class Account::Dashboard::Posts::BaseController < Account::Dashboard::BaseController
  before_action :set_post

  private

  def scoped_posts
    if current_role.in? %w(owner admin)
      @account.posts
    else
      @account.posts.where(author: current_user)
    end
  end

  def set_post
    @post = scoped_posts.find params[:post_id]
  end
end
