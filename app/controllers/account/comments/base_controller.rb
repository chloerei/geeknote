class Account::Comments::BaseController < Account::BaseController
  before_action :require_user_account
  before_action :require_sign_in
  before_action :set_comment

  private

  def set_comment
    @comment = @account.owner.comments.find(params[:comment_id])
  end
end
