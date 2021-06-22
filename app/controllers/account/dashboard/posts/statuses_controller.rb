class Account::Dashboard::Posts::StatusesController < Account::Dashboard::Posts::BaseController
  before_action :check_permission

  def update
    @post.update post_params
  end

  private

  def post_params
    params.require(:post).permit(:status)
  end

  def check_permission
    unless current_member.has_permission?(:publish_other_post) || (current_member.has_permission?(:publish_own_post) && @post.authors.include?(current_user))
      render_not_found
    end
  end
end
