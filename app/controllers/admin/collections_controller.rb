class Admin::CollectionsController < Admin::BaseController
  before_action :set_collection, only: [:show, :edit, :update]

  def index
    @collections = Collection.order(id: :desc).page(params[:page])
  end

  def show
  end

  def edit
  end

  def update
    if @collection.update collection_params
      redirect_to admin_collection_path(@collection), notice: 'User updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_collection
    @collection = Collection.find params[:id]
  end

  def collection_params
    params.require(:collection).permit(:name, :description)
  end
end
