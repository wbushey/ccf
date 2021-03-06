class OrganizationHomeController < OrganizationController
  skip_before_filter :auth_required, only: [:index]
  skip_before_filter :publically_accessible, only: [:unverified]
  def index
  end

  def unverified
    redirect_to root_path if current_organization.verified?(current_user)
    @user = current_user
  end
end
