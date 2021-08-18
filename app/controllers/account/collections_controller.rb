class Account::CollectionsController < Account::BaseController
  def index
    @collections = collection_scope.page(params[:page])
  end

  def show
    @collection = collection_scope.find params[:id]
    @posts = @collection.posts.order("collection_items.position asc").page(params[:page])
  end

  private

  def collection_scope
    if current_member
      @collections = @account.collections
    else
      @collections = @account.collections.visibility_public
    end
  end
end
