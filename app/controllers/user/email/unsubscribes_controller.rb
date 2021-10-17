class User::Email::UnsubscribesController < ApplicationController
  before_action :set_user

  def show
  end

  def update
    case params[:type]
    when 'comment'
      @user.update(comment_email_notification_enabled: false)
    end
    render turbo_stream: turbo_stream.replace('main', partial: 'success')
  end

  private

  def set_user
    # reuse verification token
    @user = User.find_by_email_auth_token(params[:token])

    unless @user
      render :expired, status: :not_found
    end
  end
end
