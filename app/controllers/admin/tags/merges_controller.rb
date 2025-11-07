class Admin::Tags::MergesController < Admin::ApplicationController
  before_action :set_tag

  def new
  end

  def create
    Tag.where(id: params[:tag_list]).each do |tag|
      @tag.merge tag
    end
    redirect_to admin_tag_path(@tag), notice: "Tags merged."
  end

  private

  def set_tag
    @tag = Tag.find params[:tag_id]
  end
end
