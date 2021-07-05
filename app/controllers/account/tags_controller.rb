class Account::TagsController < Account::BaseController
  def index
  end

  def show
    @posts = @account.posts.published.with_statuses(current_user).tagged_with(params[:id]).page(params[:page])
  end
end
