class Account::Posts::CollectionsController < Account::Posts::BaseController
  before_action :require_sign_in, :set_collection_account

  def index
    @collections = @collection_account.collections.order(updated_at: :desc).with_post_status(@post)
  end

  def new
    @collection = Collection.new
  end

  def create
    @collection = @collection_account.collections.new collection_params

    if @collection.save
      @collection.collection_items.create(post: @post)
      redirect_to account_post_collections_path(@account, @post)
    else
      render turbo_stream: turbo_stream.replace("post-#{@post.id}-collection-form", partial: "form")
    end
  end

  def update
    @collection = @collection_account.collections.find params[:id]

    if params[:collection][:added] == "1"
      @collection.collection_items.find_or_create_by(post: @post)
      flash.now[:notice] = I18n.t("flash.added_to_collection", name: @collection.name)
    else
      @collection.collection_items.find_by(post: @post)&.destroy
      flash.now[:notice] = I18n.t("flash.removed_from_collection", name: @collection.name)
    end
    render layout: "application"
  end

  def switch
    if params[:account]
      account = @current_user.manage_accounts.find_by! name: params[:account]
      session[:collection_account] = account.name
    else
      session[:collection_account] = nil
    end
    redirect_to account_post_collections_path(@account, @post)
  end

  private

  def set_collection_account
    @collection_account = find_collection_account || current_user.account
  end

  def find_collection_account
    if session[:collection_account]
      account = current_user.manage_accounts.find_by name: session[:collection_account]

      if account.nil?
        session[:collection_account] = nil
      end

      account
    end
  end

  def collection_params
    params.require(:collection).permit(:name, :description, :visibility)
  end
end
