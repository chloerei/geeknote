# Preview all emails at http://localhost:3000/rails/mailers/organization_mailer
class OrganizationMailerPreview < ActionMailer::Preview
  def invitation_user
    OrganizationMailer.with(membership: Membership.first).invitation_email
  end
end
