require "test_helper"

class RepairsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:one)
    @owner.update!(role: :owner)

    @counter = users(:two)
    @counter.update!(role: :counter)

    @staff = Staff.create!(
      name: "Test Mechanic",
      role: "Mechanic"
    )

    @other_staff = Staff.create!(
      name: "Other Mechanic",
      role: "Mechanic"
    )

    @mechanic = User.create!(
      email_address: "mechanic-test@example.com",
      password: "passwordButLong",
      role: :mechanic,
      staff: @staff
    )

    @customer = Customer.create!(
      name: "Test Customer",
      phone: "+56912345678"
    )

    @bike = Bike.create!(
      customer: @customer,
      make: "Trek",
      model: "Marlin",
      color: "Black",
      serial_number: "TEST-001"
    )

    @repair = Repair.create!(
      bike: @bike,
      mechanic: @staff,
      received_by: @owner,
      status: :diagnosing,
      customer_decision: :approved,
      received_at: Time.current,
      promised_on: Date.current + 7.days,
      quoted_price: 15000
    )

    @other_repair = Repair.create!(
      bike: @bike,
      mechanic: @other_staff,
      received_by: @owner,
      status: :diagnosing,
      received_at: Time.current,
      promised_on: Date.current + 7.days,
      quoted_price: 20000
    )

    @completed_repair = Repair.create!(
      bike: @bike,
      mechanic: @staff,
      received_by: @owner,
      status: :completed,
      received_at: 2.days.ago,
      promised_on: Date.current - 1.day,
      customer_decision: :approved,
      handed_back_at: 1.day.ago,
      quoted_price: 30000
    )
  end

  test "owner can update any repair" do
    sign_in_as @owner

    patch repair_path(@other_repair), params: {
      repair: { quoted_price: 25000 }
    }

    assert_response :redirect
    assert_equal 25000, @other_repair.reload.quoted_price
  end

  test "counter cannot update completed repair" do
    sign_in_as @counter

    patch repair_path(@completed_repair), params: {
      repair: { quoted_price: 99999 }
    }

    assert_response :forbidden
    assert_equal 30000, @completed_repair.reload.quoted_price
  end

  test "mechanic can update own active repair" do
    sign_in_as @mechanic

    patch repair_path(@repair), params: {
      repair: { status: "in_repair" }
    }

    assert_response :redirect
    assert_equal "in_repair", @repair.reload.status
  end

  test "mechanic cannot update another mechanics repair" do
    sign_in_as @mechanic

    patch repair_path(@other_repair), params: {
      repair: { status: "completed" }
    }

    assert_response :forbidden
    assert_equal "diagnosing", @other_repair.reload.status
  end

  test "mechanic cannot modify quoted price through crafted params" do
    sign_in_as @mechanic

    patch repair_path(@repair), params: {
      repair: {
        status: "in_repair",
        quoted_price: 999999,
        mechanic_id: @other_staff.id
      }
    }

    assert_response :redirect

    @repair.reload

    assert_equal "in_repair", @repair.status
    assert_equal 15000, @repair.quoted_price
    assert_equal @staff.id, @repair.mechanic_id
  end

  test "mechanic cannot view another mechanics repair" do
    sign_in_as @mechanic

    get repair_path(@other_repair)

    assert_response :forbidden
  end

  test "mechanic cannot create repairs" do
    sign_in_as @mechanic

    assert_no_difference "Repair.count" do
      post repairs_path, params: {
        repair: {
          bike_id: @bike.id,
          status: "received"
        }
      }
    end

    assert_response :forbidden
  end

  test "mechanic index excludes other mechanics repairs" do
    sign_in_as @mechanic

    get repairs_path

    assert_response :success

    assert_select "a[href='#{repair_path(@other_repair)}']",
                  count: 0
  end

  test "visitor is redirected when accessing repairs" do
    get repairs_path

    assert_redirected_to new_session_path
  end

  test "visitor can access public services" do
    get services_path

    assert_response :success
  end
end
