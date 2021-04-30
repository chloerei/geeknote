class Account::Posts::CollectionsController < Account::Posts::BaseController
  before_action :require_sign_in

  def index
    @account = current_user.account
    @collections = @account.collections
  end

  def update
    @collection = @current_user.account.collections.find params[:id]

    if params[:collection][:add] == '1'
    else
    end
  end
end
