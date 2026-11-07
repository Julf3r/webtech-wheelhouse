class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  include Pundit::Authorization
  
  after_action :verify_authorized, unless: -> { action_name == "index" }
  after_action :verify_policy_scoped, if: -> { action_name == "index" }

  rescue_from Pundit::NotAuthorizedError, with: :render_forbidden

  private

  def pundit_user
    authenticated?
    Current.user
  end

  def render_forbidden
    render "errors/forbidden", status: :forbidden
  end
end
