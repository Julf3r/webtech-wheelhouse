class StaffController < ApplicationController
  before_action :set_staff, only: %i[show edit update destroy]

  def index
    authorize Staff, :index?
    @staff = policy_scope(Staff).by_name
  end

  def show
    authorize @staff_member

    @staff_repairs = policy_scope(Repair)
      .where(mechanic_id: @staff_member.id)
      .includes(:rich_text_diagnosis, bike: :customer)
      .with_attached_intake_photos
      .by_newest_first
  end

  def new
    @staff_member = Staff.new
    authorize @staff_member
  end

  def create
    @staff_member = Staff.new(staff_params)
    authorize @staff_member

    if @staff_member.save
      redirect_to staff_path(@staff_member),
                  notice: "Staff member #{@staff_member.name} was created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @staff_member
  end

  def update
    authorize @staff_member
    if @staff_member.update(staff_params)
      redirect_to staff_path(@staff_member),
                  notice: "Staff member #{@staff_member.name} was updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @staff_member

    if @staff_member.destroy
      redirect_to staff_index_path,
                  notice: "Staff member #{@staff_member.name} was deleted.",
                  status: :see_other
    else
      redirect_to staff_path(@staff_member),
                  alert: @staff_member.errors.full_messages.to_sentence,
                  status: :see_other
    end
  end

  private

  def set_staff
    @staff_member = Staff.find(params[:id])
  end

  def staff_params
    params.expect(staff: [:name, :role])
  end
end
