class Admin::Tags::MergesController < Admin::BaseController
  before_action :set_tag

  def new
  end

  def create
    @tag.merge params[:tag_list]
    redirect_to admin_tag_path(@tag), notice: "Tags merged."
  end

  private

  def set_tag
    @tag = Tag.find params[:tag_id]
  end
end
