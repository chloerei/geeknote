class Admin::TagsController < Admin::BaseController
  before_action :set_tag, only: [ :show, :edit, :update, :destroy ]

  def index
    @pagy, @tags = pagy(Tag.order(id: :desc))
  end

  def show
  end

  def edit
  end

  def update
    if @tag.update tag_params
      redirect_to admin_tag_path(@tag), notice: "User updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @tag.destroy
    redirect_to admin_tags_path, notice: "Tag deleted."
  end

  private

  def set_tag
    @tag = Tag.find params[:id]
  end

  def tag_params
    params.require(:tag).permit(:name)
  end
end
