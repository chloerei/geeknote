class DirectUploadsController < ActiveStorage::DirectUploadsController
  before_action :check_file_limit, only: [ :create ]

  private

  def check_file_limit
    if params[:blob][:byte_size].to_i > 10.megabytes
      render json: {
        erorr: "File size limit 10 megabytes."
      }, status: 422
    end
  end
end
