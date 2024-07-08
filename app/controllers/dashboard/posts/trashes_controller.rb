class Dashboard::Posts::TrashesController < Dashboard::Posts::BaseController
  def update
    @post.trashed!
    redirect_to edit_dashboard_post_path(@account.name, @post), notice: t(".success")
  end

  def destroy
    @post.draft!
    redirect_to edit_dashboard_post_path(@account.name, @post), notice: t(".success")
  end
end
