class RepairsController < ApplicationController
  before_action :set_repair, only: %i[show edit update destroy]

  def index
    @repairs = Repair.includes(bike: :customer).by_newest_first
  end

  def show
  end

  def new
    @repair = Repair.new(
      bike_id: params[:bike_id],
      received_at: Time.current,
      status: :received
    )
    @repair.repair_services.build
  end

  def create
    @repair = Repair.new(repair_params)

    if @repair.save
      redirect_to @repair, notice: "Repair was created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    @repair.repair_services.build
  end

  def update
    if @repair.update(repair_params)
      redirect_to @repair, notice: "Repair was updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @repair.destroy
      redirect_to repairs_path,
                  notice: "Repair was deleted.",
                  status: :see_other
    else
      redirect_to @repair,
                  alert: @repair.errors.full_messages.to_sentence,
                  status: :see_other
    end
  end

  private

  def set_repair
    @repair = Repair.includes(
      bike: :customer,
      repair_services: :service
    ).find(params[:id])
  end

  def repair_params
    params.expect(
      repair: [
        :bike_id,
        :mechanic_id,
        :status,
        :promised_on,
        :received_at,
        :handed_back_at,
        :quoted_price,
        :customer_decision,
        :intake_condition,
        repair_services_attributes: [[
          :id,
          :service_id,
          :charged_price,
          :_destroy
        ]]
      ]
    )
  end
end
