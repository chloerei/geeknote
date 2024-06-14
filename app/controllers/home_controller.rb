class HomeController < ApplicationController
  before_action :require_sign_in, only: [ :following ]

  def index
    @pagy, @posts = pagy(Post.published.order(score: :desc), page: params[:page])
  end

  def following
    @pagy, @posts = pagy(Post.published.where(user_id: Current.user.followees).order(published_at: :desc), page: params[:page])
    render :index
  end

  def newest
    @pagy, @posts = pagy(Post.published.order(published_at: :desc), page: params[:page])
    render :index
  end
end
