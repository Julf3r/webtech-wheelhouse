module Api
  module V1
    class RepairsController < BaseController
      def index
        repairs = Repair
          .includes(bike: :customer, repair_services: :service)
          .by_newest_first

        if params[:state].present?
          unless Repair.statuses.key?(params[:state])
            return render json: {
              errors: [
                "Invalid state. Valid states: #{Repair.statuses.keys.join(', ')}"
              ]
            }, status: :bad_request
          end

          repairs = repairs.where(status: params[:state])
        end

        render json: repairs.map { |repair| repair_document(repair) }
      end

      def show
        repair = Repair
          .includes(bike: :customer, repair_services: :service)
          .find(params[:id])

        render json: repair_document(repair)
      end

      private

      def repair_document(repair)
        lines = repair.repair_services.map do |line|
          {
            service: line.service.name,
            charged_price: format("%.2f", line.charged_price)
          }
        end

        total = repair.repair_services.sum do |line|
          line.charged_price || 0
        end

        {
          id: repair.id,
          state: repair.status,
          received_on: repair.received_at&.to_date&.iso8601,
          promised_on: repair.promised_on&.iso8601,
          handed_back_on: repair.handed_back_at&.to_date&.iso8601,
          bike: {
            brand: repair.bike.make,
            model: repair.bike.model,
            serial_number: repair.bike.serial_number
          },
          customer: {
            name: repair.bike.customer.name
          },
          lines: lines,
          total: format("%.2f", total),
          overdue: repair.overdue?,
          customer_answer: repair.customer_decision
        }
      end
    end
  end
end
