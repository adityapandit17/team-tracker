class ApplicationController < ActionController::Base
  include Authorizable

  before_action :authenticate_user!, unless: :devise_controller?
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_audit_context

  helper_method :can?, :cannot?, :owns_record?, :team_lead_options, :accessible_developer?, :scoped_developers

  layout :resolve_layout

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  private

  def set_audit_context
    Current.user = current_user if user_signed_in?
    Current.ip_address = request.remote_ip
    Current.request_uuid = request.request_id
  end

  def resolve_layout
    if devise_controller? && !(controller_name == "registrations" && action_name.in?(%w[edit update]))
      "devise"
    else
      "application"
    end
  end
end
