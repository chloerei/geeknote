class Dashboard::Posts::RevisionsController < Dashboard::Posts::BaseController
  def index
    @revision = @post.revisions.order(id: :desc).first
    @previous = @post.revisions.where(id: ...@revision.id).order(id: :desc).first if @revision

    @page_titles.prepend t(".index.title")
    render layout: "application"
  end

  def show
    @revision = @post.revisions.find(params[:id])
    @previous = @post.revisions.where(id: ...@revision.id).order(id: :desc).first

    @page_titles.prepend "#{t(".show.title")} · #{I18n.l(@revision.created_at, format: :long)}"
    render layout: "application"
  end

  def list
    @pagy, @revisions = pagy(@post.revisions.includes(:user).order(id: :desc))
    render partial: "revision_list"
  end

  def restore
    revision = @post.revisions.find(params[:id])

    if @post.update(title: revision.title, content: revision.content)
      redirect_to edit_dashboard_post_path(@account.name, @post), notice: t(".success")
    else
      redirect_to dashboard_post_revision_path(@account.name, @post, revision), alert: t(".failure")
    end
  end
end
