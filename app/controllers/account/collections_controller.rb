class Account::CollectionsController < Account::BaseController
  def index
    @paginator = RailsCursorPagination::Paginator.new(collection_scope, order_by: :updated_at, order: :desc, after: params[:after]).fetch
  end

  def show
    @collection = collection_scope.find params[:id]

    @paginator = RailsCursorPagination::Paginator.new(@collection.collection_items.preload(post: [ :account, :user ]), order_by: :position, order: :asc, after: params[:after]).fetch
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
