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

  def restore
    @revision = @post.revisions.find params[:id]
    @post.update(
      title: @revision.title,
      content: @revision.content
    )
    @post.save_revision(user: current_user)
    redirect_to edit_account_dashboard_post_url(@account, @post), notice: I18n.t('flash.post_restore_to_revision', name: @revision.display_name)
  end
end
