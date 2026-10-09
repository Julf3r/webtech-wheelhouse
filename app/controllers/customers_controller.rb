
class CustomersController < ApplicationController
  before_action :set_customer, only: %i[show edit update destroy]

  def index
    @customers = Customer.by_name
  end

  def show
  end

  def new
    @customer = Customer.new
  end

  def create
    @customer = Customer.new(customer_params)

    if @customer.save
      redirect_to @customer, notice: "Customer #{@customer.name} was created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @customer.update(customer_params)
      redirect_to @customer, notice: "Customer #{@customer.name} was updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @customer = Customer.find(params[:id])

    if @customer.destroy
      redirect_to customers_path, notice: "Customer #{@customer.name} was deleted.", status: :see_other
    else
      redirect_to @customer, alert: @customer.errors.full_messages.to_sentence
    end
  end

  private

  def set_customer
    @customer = Customer.includes(:bikes).find(params[:id])
  end

  def customer_params
    params.expect(customer: [:name, :phone])
  end
end
