class Account::Posts::CollectionsController < Account::Posts::BaseController
  before_action :require_sign_in

  before_action :set_collection, only: [:update, :destroy]

  def index
    @target_account = if params[:account]
      current_user.manage_accounts.find_by! name: params[:account]
    else
      current_user.account
    end

    @collections = @target_account.collections.with_post_added(@post)
  end

  def update
    flash.now[:notice] = "Added to #{@collection.name}"
    @collection.added = true
    @collection.collection_items.find_or_create_by(post: @post)

  end

  def destroy
    flash.now[:notice] = "Removed from #{@collection.name}"
    @collection.added = false
    @collection.collection_items.where(post: @post).destroy_all
    render :update
  end

  private

  def set_collection
    @collection = Collection.find params[:id]

    unless @collection.account.can_manage_by? current_user
      render_not_found
    end
  end
end
