class Account::SearchController < Account::BaseController
  def index
    if params[:query].present?
      @posts = Post.includes(:account, :user).search(params[:query], filter: "status = 'published' AND account_id = #{@account.id}").page(params[:page])
    else
      @posts = Post.published.includes(:account, :user).where(account_id: @account.id).order(published_at: :desc).page(params[:page])
    end
  end
end
