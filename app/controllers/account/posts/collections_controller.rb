class Account::Posts::CollectionsController < Account::Posts::BaseController
  before_action :require_sign_in

  def index
    @target_account = if params[:account]
      current_user.manage_accounts.find_by! name: params[:account]
    else
      current_user.account
    end

    @collections = @target_account.collections.with_post_added(@post)
  end

  def update
    @collection = Collection.find params[:id]

    unless current_user.account == @collection.account || current_user.manage_accounts.include?(@collection.account)
      render_not_found and return
    end

    if params[:collection][:added] == '1'
      flash.now[:notice] = "Added to #{@collection.name}"
      @collection.added = true
      @collection.collection_items.find_or_create_by(post: @post)
    else
      flash.now[:notice] = "Removed from #{@collection.name}"
      @collection.added = false
      @collection.collection_items.where(post: @post).destroy_all
    end
  end
end
