class Account::Posts::Comments::BaseController < Account::Posts::BaseController
  before_action :set_comment

  private

  def set_comment
    @comment = @post.comments.find params[:comment_id]
  end
end
