class Account::Dashboard::Posts::SettingsController < Account::Dashboard::Posts::BaseController
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
    if @account.user?
      params.require(:post).permit(:excerpt, :allow_comments, :featured, tag_list: [])
    else
      params.require(:post).permit(:excerpt, :allow_comments, :featured, tag_list: [], author_list: [])
    end
  end
end
