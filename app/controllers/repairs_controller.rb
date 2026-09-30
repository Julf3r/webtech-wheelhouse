class RepairsController < ApplicationController
  def index
    @repairs = Repair.includes(bike: :customer).by_newest_first
  end

  def show
    @repair = Repair.includes(:bike, repair_services: :services).find(params[:id])
  end
end