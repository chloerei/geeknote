class Account::PostsController < Account::BaseController
  def index
  end

  def show
    @post = @account.posts.find params[:id]
  end
end
