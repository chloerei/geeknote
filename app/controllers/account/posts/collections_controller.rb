class Account::Posts::CollectionsController < Account::Posts::BaseController
  before_action :require_sign_in

  def index
    @collections = current_user.account.collections.includes(:collection_items)
  end

  def update
    @collection = current_user.account.collections.find params[:id]

    if params[:collection][:added] == '1'
      flash.now[:notice] = "Added to #{@collection.name}"
      @collection.collection_items.find_or_create_by(post: @post)
    else
      flash.now[:notice] = "Removed from #{@collection.name}"
      @collection.collection_items.where(post: @post).destroy_all
    end
  end
end
