module Api
  module V1
    class BaseController < ActionController::API
      include ActionController::HttpAuthentication::Token::ControllerMethods

      before_action :authenticate_api_token!

      rescue_from ActiveRecord::RecordNotFound do
        render json: { errors: ["Record not found"] },
               status: :not_found
      end

      rescue_from ActionController::ParameterMissing,
                  ActionController::BadRequest do |error|
        render json: { errors: [error.message] },
               status: :bad_request
      end

      private

      def authenticate_api_token!
        expected = Rails.application.credentials.api_token.to_s

        authenticated = authenticate_with_http_token do |token, _options|
          expected.present? &&
            ActiveSupport::SecurityUtils.secure_compare(token, expected)
        end

        return if authenticated

        render json: { errors: ["Invalid or missing API token"] },
               status: :unauthorized
      end
    end
  end
end
