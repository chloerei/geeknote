class Admin::AccountsController < Admin::BaseController
  before_action :set_account, only: [ :show, :edit, :update, :destroy ]

  def index
    @pagy, @accounts = pagy(Account.order(id: :desc))
  end

  def show
  end

  def edit
  end

  def update
    if @account.update account_params
      redirect_to admin_account_path(@account.id), notice: "Account updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @account.destroy
    redirect_to admin_accounts_path, notice: "Account deleted."
  end

  private

  def set_account
    @account = Account.find params[:id]
  end

  def account_params
    params.require(:account).permit(:name, :feed_url, :feed_mark_canonical)
  end
end
