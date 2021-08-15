class Account::Dashboard::CollectionsController < Account::Dashboard::BaseController
  before_action :check_manage_permission

  def index
    @collections = @account.collections.order(updated_at: :desc).page(params[:page])
  end

  def show
    @collection = @account.collections.find params[:id]
    @collection_items = @collection.collection_items.order(position: :asc).includes(post: :account).page(params[:page])
  end

  def new
    @collection = @account.collections.new
  end

  def create
    @collection = @account.collections.new collection_params

    if @collection.save
      redirect_to account_dashboard_collection_path(@account, @collection), notice: I18n.t('flash.collection_created', name: @collection.name)
    else
      render turbo_stream: turbo_stream.replace('collection-form', partial: 'form')
    end
  end

  def edit
    @collection = @account.collections.find params[:id]
  end

  def update
    @collection = @account.collections.find params[:id]

    if @collection.update collection_params
      redirect_to account_dashboard_collection_path(@account, @collection), notice: I18n.t('flash.collection_updated', name: @collection.name)
    else
      render turbo_stream: turbo_stream.replace('collection-form', partial: 'form')
    end
  end

  def destroy
    @collection = @account.collections.find params[:id]
    @collection.destroy
      redirect_to account_dashboard_collections_path(@account), notice: I18n.t('flash.collection_deleted', name: @collection.name)
  end

  private

  def check_manage_permission
    unless current_member.has_permission?(:manage_collections)
      render_not_found
    end
  end

  def collection_params
    params.require(:collection).permit(:name, :description, :visibility, :order_type)
  end
end
