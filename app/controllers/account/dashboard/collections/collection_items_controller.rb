class Account::Dashboard::Collections::CollectionItemsController < Account::Dashboard::Collections::BaseController
  before_action :set_collection_item

  def update
    @collection.order_type_custom!
    @collection_item.move_to params[:collection_item][:position].to_i
  end

  def destroy
    @collection_item.destroy
    render turbo_stream: turbo_stream.remove("collection-item-#{@collection_item.id}")
  end

  private

  def set_collection_item
    @collection_item = @collection.collection_items.find params[:id]
  end
end
