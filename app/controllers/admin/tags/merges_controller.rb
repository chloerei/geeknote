class Admin::Tags::MergesController < Admin::BaseController
  before_action :set_tag

  def new
  end

  # TODO: tag_list array to string
  def create
    @tag.merge params[:tag_list]
    redirect_to admin_tag_path(@tag)
  end

  private

  def set_tag
    @tag = Tag.find params[:tag_id]
  end
end
