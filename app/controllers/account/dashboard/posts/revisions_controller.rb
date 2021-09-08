class Account::Dashboard::Posts::RevisionsController < Account::Dashboard::Posts::BaseController
  layout 'base'

  def index
    @revisions = @post.revisions.order(id: :desc).page(params[:page])
    if params[:page].nil?
      @revision = @post.revisions.last
    end
  end

  def show
    @revision = @post.revisions.find params[:id]
  end
end
