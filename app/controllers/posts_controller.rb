class PostsController < ApplicationController
  before_action :require_sign_in, only: [:following]

  def index
    @posts = Post.published.order(id: :desc).page(params[:page])
  end

  def following
    @posts = Post.published.following_by(current_user).order(published_at: :desc).page(params[:page])
    render :index
  end

  def latest
    @posts = Post.published.order(published_at: :desc).page(params[:page])
    render :index
  end
end
