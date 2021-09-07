class Account::Dashboard::Posts::RevisionsController < Account::Dashboard::Posts::BaseController
  layout 'base'

  def index
    @revisions = @post.revisions.order(id: :desc)
    @revision = @post.revisions.last
  end
end
