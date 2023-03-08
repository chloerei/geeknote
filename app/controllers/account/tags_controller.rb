class Account::TagsController < Account::BaseController
  def show
    @tag = Tag.find_or_initialize_by name: params[:id]
    @posts = @account.posts.tagged_with(@tag.name).page(params[:page])
  end
end
