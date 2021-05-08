class Account::Dashboard::CollectionsController < Account::Dashboard::BaseController
  before_action :require_account_admin, except: [:index, :show]
  before_action :set_collection, only: [:show, :edit, :update, :destroy]

  def index
    @collections = @account.collections.page(params[:page])
  end

  def new
    @collection = @account.collections.new
  end

  def create
    @collection = @account.collections.new collection_params

    if @collection.save
      redirect_to account_dashboard_collection_path(@account, @collection)
    else
      render turbo_stream: turbo_stream.replace('collection-form', partial: 'form')
    end
  end

  def show
  end

  def edit
  end

  def update
    if @collection.update collection_params
      redirect_to account_dashboard_collection_path(@account, @collection)
    else
      render turbo_stream: turbo_stream.replace('collection-form', partial: 'form')
    end
  end

  def destroy
    @collection.destroy
    redirect_to account_dashboard_collections_path(@account)
  end

  private

  def collection_params
    params.require(:collection).permit(:name, :description, :visibility, :cover)
  end

  def set_collection
    @collection = @account.collections.find params[:id]
  end
end
