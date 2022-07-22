class Account::TagsController < Account::BaseController
  def index
  end

  def show
    @posts = @account.posts.tagged_with(params[:id]).page(params[:page])
  end
end
