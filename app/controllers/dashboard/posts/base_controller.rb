class Dashboard::Posts::BaseController < Dashboard::BaseController
  before_action :set_post

  private

  def set_post
    @post = post_scope.find(params[:post_id])
  end

  def post_scope
    if @account.user?
      Current.user.posts
    else
      if @member.owner? || @member.admin?
        @account.posts
      else
        @account.posts.where(user: Current.user)
      end
    end
  end
end
