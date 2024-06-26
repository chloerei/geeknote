class UserMailer < ApplicationMailer
  helper :application, :markdown

  def password_reset_email
    @user = params[:user]

    mail(
      to: @user.email,
      subject: I18n.t("email.reset_your_geeknote_password")
    )
  end

  def email_verification
    @user = params[:user]

    mail(
      to: @user.email,
      subject: I18n.t("email.email_verification")
    )
  end

  def commented_notification
    @notification = params[:notification]
    @user = @notification.user
    @comment = @notification.comment

    options = {
      to: @user.email,
      from: "#{@comment.user.name} <#{ENV['MAILER_FROM_DEFAULT']}>",
      subject: "Re: #{@comment.commentable.title}",
      message_id: "#{@comment.user.account.name}/comments/#{@comment.id}@geeknote.net",
      references: "#{@comment.user.account.name}/#{@comment.commentable_type.downcase}/#{@comment.commentable_id}@geeknote.net"
    }

    if @comment.parent
      options[:in_reply_to] = "#{@comment.user.account.name}/comments/#{@comment.parent_id}@geeknote.net"
    end

    mail(options)
  end

  def post_blocked_notification
    @notification = params[:notification]
    @user = @notification.user
    @post = @notification.post

    mail(
      from: "#{@site.name} <#{ENV['MAILER_FROM_SUPPORT']}>",
      to: @user.email,
      subject: "Post Blocked: #{@notification.post.title}"
    )
  end

  def weekly_digest
    @user = params[:user]

    @posts = Post
      .from(Post.select("*, rank() over (partition by account_id order by likes_count desc, published_at desc)")
      .published
      .where(published_at: [ Date.today - 7 .. Date.today ])
      .where("likes_count > 0"), :posts)
      .where(rank: 1)
      .order(likes_count: :desc, published_at: :desc)
      .limit(5)
      .to_a

    mail(
      from: "#{@site.name} Weekly <#{ENV['MAILER_FROM_DIGEST']}>",
      to: @user.email,
      subject: I18n.t("common.weekly_digest_subject", title: @posts.first&.title, count: @posts.length)
    )
  end
end
