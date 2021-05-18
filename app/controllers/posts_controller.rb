class PostsController < ApplicationController
  before_action :require_sign_in, only: [:following]

  def index
    @posts = Post.published.order(id: :desc).page(params[:page])
  end

  def following
    @posts = Post.published.where(account: current_user.followings).page(params[:page])
    render :index
  end
end
