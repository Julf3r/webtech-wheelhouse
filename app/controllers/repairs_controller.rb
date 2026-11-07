class RepairsController < ApplicationController
  before_action :set_repair, only: %i[show edit update destroy purge_photo]
  def index
    authorize Repair, :index?
    @repairs = policy_scope(Repair)
      .includes(bike: :customer)
      .with_attached_intake_photos
      .with_rich_text_diagnosis
      .by_newest_first
  end

  def show
    authorize @repair
  end

  def new
    @repair = Repair.new(
      bike_id: params[:bike_id],
      received_at: Time.current,
      status: :received
    )
    authorize @repair
    @repair.repair_services.build
  end

  def create
    @repair = Repair.new
    authorize @repair

    @repair.assign_attributes(repair_params)
    @repair.received_by = Current.user

    if @repair.save
      redirect_to @repair, notice: "Repair was created."
    else
      @repair.repair_services.build if @repair.repair_services.empty?
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @repair

    @repair.repair_services.build
  end

  
  def update
    authorize @repair
    attributes = repair_params
    new_photos = attributes.delete(:intake_photos)

    @repair.assign_attributes(attributes)

    if new_photos.present?
      @repair.intake_photos =
        @repair.intake_photos.blobs.to_a + new_photos
    end

    if @repair.save
      redirect_to @repair, notice: "Repair was updated."
    else
      render :edit, status: :unprocessable_content
    end
  end


  def destroy
    authorize @repair

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

  def purge_photo
    authorize @repair, :purge_photo?
    photo = @repair.intake_photos.attachments.find(params[:attachment_id])
    photo.purge

    redirect_to edit_repair_path(@repair),
                notice: "Photo removed.",
                status: :see_other
  end

  private

  def set_repair
    @repair = Repair
      .includes(bike: :customer, repair_services: :service)
      .with_attached_intake_photos
      .with_rich_text_diagnosis
      .find(params[:id])
  end

  
  def repair_params
    params.expect(repair: policy(@repair).permitted_attributes)
  end
end