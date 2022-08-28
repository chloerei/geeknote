class UserMailer < ApplicationMailer
  helper :application

  def password_reset_email
    @user = params[:user]

    mail(
      to: @user.email,
      subject: I18n.t('email.reset_your_geeknote_password')
    )
  end

  def post_restricted_email
    @user = params[:user]
    @post = params[:post]

    mail(
      from: "#{@site.name} <#{ENV['MAILER_FROM_SUPPORT']}>",
      to: @user.email,
      subject: I18n.t('email.your_post_is_been_restricted_for_publish')
    )
  end

  def email_verification
    @user = params[:user]

    mail(
      to: @user.email,
      subject: I18n.t('email.email_verification')
    )
  end

  def comment_notification
    @user = params[:user]
    @comment = params[:comment]

    options = {
      to: @user.email,
      from: "#{@comment.user.name} <#{ENV['MAILER_FROM_DEFAULT']}>",
      subject: "Re: #{@comment.commentable.title}",
      message_id: "#{@comment.account.name}/posts/#{@comment.commentable_id}/comments/#{@comment.id}@geeknote.net",
      references: "#{@comment.account.name}/posts/#{@comment.commentable_id}@geeknote.net"
    }

    if @comment.parent
      options[:in_reply_to] = "#{@comment.account.name}/posts/#{@comment.commentable_id}/comments/#{@comment.parent_id}@geeknote.net"
    end

    mail(options)
  end

  def weekly_summary
    @user = params[:user]

    @posts = Post.published.where(published_at: [Date.today - 7 .. Date.today]).where("likes_count > 0").order(likes_count: :desc).limit(10)

    mail(
      from: "#{@site.name} Weekly <#{ENV['MAILER_FROM_DIGEST']}>",
      to: @user.email,
      subject: I18n.t('common.weekly_summary_subject', title: @posts.first.title, count: @posts.count)
    )
  end
end
