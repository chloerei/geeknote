class Account::CollectionsController < Account::BaseController
  def index
    @collections = @account.collections.order(updated_at: :desc).page(params[:page])
  end

  def show
    @collection = @account.collections.find params[:id]
    @posts = @collection.posts.order('collection_items.created_at': :desc).page(params[:page])
  end
end
