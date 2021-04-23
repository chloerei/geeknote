class OrganizationMailer < ApplicationMailer
  def invitation_email
    @membership = params[:membership]

    email = @membership.user ? @membership.user.email : @membership.invitation_email

    mail(to: email, subject: "Member invitation")
  end
end
