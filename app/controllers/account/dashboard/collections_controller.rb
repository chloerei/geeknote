class Account::Dashboard::CollectionsController < Account::Dashboard::BaseController
  before_action :check_manage_permission

  def index
    @collections = @account.collections.order(updated_at: :desc).page(params[:page])
  end

  def show
    @collection = @account.collections.find params[:id]
    @collection_items = @collection.collection_items.order(created_at: :desc).includes(post: :account).page(params[:page])
  end

  private

  def check_manage_permission
    unless current_member.has_permission?(:manage_collections)
      render_not_found
    end
  end
end
