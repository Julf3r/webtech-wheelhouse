class RepairsController < ApplicationController
  before_action :set_repair, only: %i[show edit update destroy purge_photo]
  def index
  @repairs = Repair
    .includes(bike: :customer)
    .with_attached_intake_photos
    .with_rich_text_diagnosis
    .by_newest_first
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
        :diagnosis,
        repair_services_attributes: [[
          :id,
          :service_id,
          :charged_price,
          :_destroy
        ]],
        intake_photos: []
      ]
    )
  end
end