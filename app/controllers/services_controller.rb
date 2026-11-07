
class ServicesController < ApplicationController
  before_action :set_service, only: %i[show edit update destroy]

  def index
    authorize Service, :index?
    @services = policy_scope(Service).by_name
  end

  def show
    authorize @service
  end

  def new
    @service = Service.new
    authorize @service
  end

  def create
    @service = Service.new(service_params)
    authorize @service

    if @service.save
      redirect_to @service, notice: "Service #{@service.name} was created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @service
  end

  def update
    authorize @service
    if @service.update(service_params)
      redirect_to @service, notice: "Service #{@service.name} was updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @service

    if @service.destroy
      redirect_to services_path, notice: "Service #{@service.name} was deleted.", status: :see_other
    else
      redirect_to @service, alert: @service.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private

  def set_service
    @service = Service.find(params[:id])
  end

  def service_params
    params.expect(service: [:name, :current_price])
  end

  allow_unauthenticated_access only: %i[index show]
end
