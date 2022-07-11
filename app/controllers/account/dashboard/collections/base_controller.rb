class Account::Dashboard::Collections::BaseController < Account::Dashboard::BaseController
  before_action :check_manage_permission, :set_collection

  private

  def check_manage_permission
    unless current_member.role.in?(%w(owner admin))
      render_not_found
    end
  end

  def set_collection
    @collection = @account.collections.find params[:collection_id]
  end
end
