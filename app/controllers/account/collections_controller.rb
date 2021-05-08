class Account::CollectionsController < Account::BaseController
  def index
    @collections = collection_scope.order(updated_at: :desc).page(params[:page])
  end

  def show
    @collection = collection_scope.find params[:id]
    @posts = @collection.posts.order('collection_items.created_at': :desc).page(params[:page])
  end

  private

  def collection_scope
    if @account.has_member?(current_user)
      @account.collections
    else
      @account.collections.visibility_public
    end
  end
end
