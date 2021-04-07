class Space::Dashboard::Posts::SettingsController < Space::Dashboard::Posts::BaseController
  layout 'base'

  def show
  end

  def update
    if @post.update settings_params
      # render nothing
    else
      render turbo_stream: turbo_stream.replace('settings-form', partial: 'form')
    end
  end

  private

  def settings_params
    params.require(:post).permit(:summary)
  end
end
