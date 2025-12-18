class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!


  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Use auth layout for Devise controllers
  layout :layout_by_resource

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  def layout_by_resource
    if devise_controller?
      'auth'
    else
      'application'
    end
  end
end
