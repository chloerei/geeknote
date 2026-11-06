class Account::FollowersController < Account::BaseController
  def index
    @pagy, @accounts = pagy(:offset, @account.follower_accounts.order("follows.created_at DESC"), page: params[:page])
    @page_titles.prepend t("general.followers")
  end
end
