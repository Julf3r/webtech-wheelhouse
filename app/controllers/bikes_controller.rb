class BikesController < ApplicationController
  def index
    @bikes = Bike.includes(:customer).by_make_and_model
  end

  def show
    @bike = Bike.includes(:customer, :repairs).find(params[:id])
  end
end