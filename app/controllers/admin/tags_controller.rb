class Admin::TagsController < Admin::BaseController
  before_action :set_tag, only: [:show, :edit, :update]

  def index
    @tags = Tag.order(id: :desc).page(params[:page])
  end

  def show
  end

  def edit
  end

  def update
    if @tag.update tag_params
      redirect_to admin_tag_path(@tag), notice: 'User updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_tag
    @tag = Tag.find params[:id]
  end

  def tag_params
    params.require(:tag).permit(:name)
  end
end
