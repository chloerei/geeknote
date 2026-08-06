class Organizations::LeavesController < ApplicationController
  before_action :require_authentication

  def destroy
    @organization = Current.user.organizations.find(params[:organization_id])
    @member = @organization.members.find_by!(user: Current.user)

    if @member.admin? && @organization.members.admin.active.where.not(id: @member.id).none?
      redirect_to dashboard_settings_root_path(@organization.account.name), alert: t(".cannot_leave_last_admin")
    else
      @member.destroy
      redirect_to organizations_path, notice: t(".left")
    end
  end
end
