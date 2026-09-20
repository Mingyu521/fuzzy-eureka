module Api
  class BaseController < ActionController::API
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActiveRecord::RecordInvalid, with: :unprocessable
    rescue_from ActionController::ParameterMissing, with: :bad_request

    private

    def authenticate_project!
      token = request.headers["Authorization"].to_s.delete_prefix("Bearer ").strip
      @current_project = token.present? ? Project.find_by(api_key: token) : nil
      render json: { error: "Invalid or missing API key" }, status: :unauthorized unless @current_project
    end

    def current_project
      @current_project
    end

    def not_found
      render json: { error: "Not found" }, status: :not_found
    end

    def bad_request(exception)
      render json: { error: exception.message }, status: :bad_request
    end

    def unprocessable(exception)
      render json: { error: exception.record.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end
end
