# Preview all emails at http://localhost:3000/rails/mailers/organization_mailer
class OrganizationMailerPreview < ActionMailer::Preview
  def invitation_user
    member = Member.pending.first || FactoryBot.create(:invitation)
    OrganizationMailer.with(member: member).invitation_email
  end
end
