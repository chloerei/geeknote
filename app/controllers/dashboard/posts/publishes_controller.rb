class Dashboard::Posts::PublishesController < Dashboard::Posts::BaseController
  def update
    @post.published!
    redirect_to edit_dashboard_post_path(@account.name, @post), notice: "Post published"
  end

  def destroy
    @post.draft!
    redirect_to edit_dashboard_post_path(@account.name, @post), notice: "Post unpublished"
  end
end
