class Account::Posts::CollectionsController < Account::Posts::BaseController
  before_action :require_sign_in, :set_saved_account

  def index
    @collections = @saved_account.collections.order(updated_at: :desc).with_post_status(@post)
  end

  def new
    @collection = Collection.new
  end

  def create
    @collection = @saved_account.collections.new collection_params

    if @collection.save
      redirect_to account_post_collections_path
    else
      render turbo_stream: turbo_stream.replace("post-#{@post.id}-collection-form", partial: 'form')
    end
  end

  def update
    @collection = @saved_account.collections.find params[:id]

    if params[:collection][:added] == '1'
      @collection.collection_items.find_or_create_by(post: @post)
    else
      @collection.collection_items.find_by(post: @post)&.destroy
    end
  end

  private

  def set_saved_account
    @saved_account = current_user.account
  end

  def collection_params
    params.require(:collection).permit(:name, :description, :visibility)
  end
end
