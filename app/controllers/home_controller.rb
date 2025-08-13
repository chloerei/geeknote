class HomeController < ApplicationController
  before_action :require_authentication, only: [ :following ]

  def index
    @pagy, @posts = pagy(Post.published.order(score: :desc).includes(:account, :user))
    @page_titles.prepend t("general.home")
  end

  def following
    follow_accounts = Current.user.followings
    follow_users = Current.user.following_users
    @pagy, @posts = pagy(
      Post.published.order(published_at: :desc).where(account: follow_accounts)
        .or(Post.published.order(published_at: :desc).where(user: follow_users))
        .includes(:account, :user)
    )
    @page_titles.prepend t("general.following")
    render :index
  end

  def newest
    @pagy, @posts = pagy(Post.published.order(published_at: :desc).includes(:account, :user))
    @page_titles.prepend t("general.newest")
    render :index
  end

  def sidebar
    render layout: "application"
  end
end
