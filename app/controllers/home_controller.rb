class HomeController < ApplicationController
  before_action :require_sign_in, only: [:feed]

  def index
    @posts = Post.published.hot.where("published_at > ?", 3.month.ago).includes(:tags, :account).page(params[:page])
  end

  def feed
    @posts = Post.published.following_by(current_user).order(published_at: :desc).page(params[:page])
    render :index
  end

  def newest
    @posts = Post.published.order(published_at: :desc).page(params[:page])
    render :index
  end
end
