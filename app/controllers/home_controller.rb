class HomeController < ApplicationController
  before_action :require_sign_in, only: [ :feed ]

  def index
    @paginator = RailsCursorPagination::Paginator.new(Post.published.where("score > 0").includes(:account, :user), order_by: :score, order: :desc, after: params[:after]).fetch
  end

  def feed
    @paginator = RailsCursorPagination::Paginator.new(Post.published.following_by(current_user).includes(:account, :user), order_by: :published_at, order: :desc, after: params[:after]).fetch
    render :index
  end

  def newest
    @paginator = RailsCursorPagination::Paginator.new(Post.published.includes(:account, :user), order_by: :published_at, order: :desc, after: params[:after]).fetch
    render :index
  end
end
