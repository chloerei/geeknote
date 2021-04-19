class Account::Dashboard::Posts::BaseController < Account::Dashboard::BaseController
  before_action :set_post

  private

  def set_post
    @post = @account.posts.find params[:post_id]
  end
end
