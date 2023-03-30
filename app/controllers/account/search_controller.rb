class Account::SearchController < Account::BaseController
  def index
    if params[:query].present?
      @posts = Post.search(params[:query], filter: "status = 'published' AND account_id = #{@account.id}").page(params[:page])
    end
  end
end
