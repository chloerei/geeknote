class Account::Dashboard::Posts::BaseController < Account::Dashboard::BaseController
  before_action :set_post

  private

  def scoped_posts
    if current_member.has_permission?(:edit_other_post)
      @account.posts
    else
      @account.posts.joins(:authors).where(authors: { user: current_user })
    end
  end

  def set_post
    @post = scoped_posts.find params[:post_id]
  end
end
