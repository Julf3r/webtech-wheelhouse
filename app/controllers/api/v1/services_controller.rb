module Api
  module V1
    class ServicesController < BaseController
      skip_before_action :authenticate_api_token!,
                         only: %i[index show]

      def index
        services = Service.by_name
          .left_joins(:repair_services)
          .select(
            "services.*, COUNT(repair_services.id) AS charged_repairs_count"
          )
          .group("services.id")

        render json: services.map { |service| service_document(service) }
      end

      def show
        service = Service.find(params[:id])
        render json: service_document(service)
      end

      def create
        attributes = service_params

        if attributes.empty?
          return render json: {
            errors: ["No service attributes provided"]
          }, status: :bad_request
        end

        service = Service.new(attributes)

        if service.save
          render json: service_document(service),
                 status: :created,
                 location: api_v1_service_url(service)
        else
          render json: {
            errors: service.errors.full_messages
          }, status: :unprocessable_content
        end
      end

      private

      def service_params
        params.expect(service: [:name, :current_price])
      end

      def service_document(service)
        count = if service.has_attribute?(:charged_repairs_count)
          service.read_attribute(:charged_repairs_count).to_i
        else
          service.repair_services.count
        end

        {
          id: service.id,
          name: service.name,
          price: format("%.2f", service.current_price),
          charged_repairs_count: count
        }
      end
    end
  end
end
