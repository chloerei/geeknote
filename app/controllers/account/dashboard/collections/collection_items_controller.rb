class Account::Dashboard::Collections::CollectionItemsController < Account::Dashboard::Collections::BaseController
  def destroy
    @collection_item = @collection.collection_items.find params[:id]
    @collection_item.destroy
    render turbo_stream: turbo_stream.remove("collection-item-#{@collection_item.id}")
  end
end
