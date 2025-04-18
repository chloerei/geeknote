class Dashboard::Settings::MembersController < Dashboard::Settings::BaseController
  before_action :require_organization_account

  def index
    @page_titles.prepend t("general.members")
  end

  def new
    @member = @organization.members.new role: "member"
    @page_titles.prepend t("general.new_member")
  end

  def create
    @member = @organization.members.new(params.require(:member).permit(:invitation_email, :role))

    if @member.save
      redirect_to dashboard_settings_members_path, notice: "Member has been added"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @member = @organization.members.find(params[:id])
    @page_titles.prepend t("general.edit_member")
  end

  def update
    @member = @organization.members.find(params[:id])

    if @member.update(params.require(:member).permit(:role))
      redirect_to dashboard_settings_members_path, notice: "Member has been updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @member = @organization.members.find(params[:id])

    # not the last admin
    if @organization.members.admin.where.not(id: @member.id).exists?
      @member.destroy
    end

    redirect_to dashboard_settings_members_path, notice: "Member has been removed"
  end
end
