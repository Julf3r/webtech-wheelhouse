class StaffController < ApplicationController
  def index
    @staff = Staff.by_name
  end

  def show
    @staff_member = Staff.find(params[:id])
  end
end
