
class BikesController < ApplicationController
  before_action :set_bike, only: %i[show edit update destroy]

  def index
    @bikes = Bike.includes(:customer).by_make_and_model
  end

  def show
  end

  def new
    @bike = Bike.new(customer_id: params[:customer_id])
  end

  def create
    @bike = Bike.new(bike_params)

    if @bike.save
      redirect_to @bike, notice: "Bike #{@bike.serial_number} was created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @bike.update(bike_params)
      redirect_to @bike, notice: "Bike #{@bike.serial_number} was updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @bike.destroy
      redirect_to bikes_path, notice: "Bike #{@bike.serial_number} was deleted.", status: :see_other
    else
      redirect_to @bike, alert: @bike.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private

  def set_bike
    @bike = Bike.includes(:customer, :repairs).find(params[:id])
  end

  def bike_params
    params.expect(bike: [:customer_id, :make, :model, :color, :serial_number])
  end
end
