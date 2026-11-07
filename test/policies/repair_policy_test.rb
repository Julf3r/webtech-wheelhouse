require "test_helper"

class RepairPolicyTest < ActiveSupport::TestCase
  setup do
    @owner = User.new(role: :owner)
    @counter = User.new(role: :counter)

    @mechanic = User.new(role: :mechanic, staff_id: 101)
    @other_mechanic = User.new(role: :mechanic, staff_id: 202)
    @unlinked_mechanic = User.new(role: :mechanic)

    @active_repair = Repair.new(
      mechanic_id: 101,
      status: :diagnosing
    )

    @completed_repair = Repair.new(
      mechanic_id: 101,
      status: :completed
    )

    @unassigned_repair = Repair.new(
      status: :diagnosing
    )
  end

  test "owner can manage completed repairs" do
    policy = RepairPolicy.new(@owner, @completed_repair)

    assert policy.show?
    assert policy.update?
    assert policy.destroy?
  end

  test "counter can create and read repairs" do
    policy = RepairPolicy.new(@counter, @active_repair)

    assert policy.show?
    assert policy.create?
    refute policy.destroy?
  end

  test "counter cannot update completed repairs" do
    policy = RepairPolicy.new(@counter, @completed_repair)

    refute policy.update?
  end

  test "mechanic can read and update own active repair" do
    policy = RepairPolicy.new(@mechanic, @active_repair)

    assert policy.show?
    assert policy.update?
  end

  test "mechanic cannot access another mechanics repair" do
    policy = RepairPolicy.new(@other_mechanic, @active_repair)

    refute policy.show?
    refute policy.update?
  end

  test "mechanic cannot update completed repair" do
    policy = RepairPolicy.new(@mechanic, @completed_repair)

    assert policy.show?
    refute policy.update?
  end

  test "mechanic cannot create or delete repairs" do
    policy = RepairPolicy.new(@mechanic, @active_repair)

    refute policy.create?
    refute policy.destroy?
  end

  test "unlinked mechanic cannot access unassigned repairs" do
    policy = RepairPolicy.new(@unlinked_mechanic, @unassigned_repair)

    refute policy.show?
    refute policy.update?
  end

  test "mechanic can only submit permitted repair attributes" do
    attributes = RepairPolicy.new(
      @mechanic, @active_repair
    ).permitted_attributes

    assert_includes attributes, :status
    assert_includes attributes, :diagnosis

    refute_includes attributes, :quoted_price
    refute_includes attributes, :bike_id
    refute_includes attributes, :mechanic_id
    refute_includes attributes, :handed_back_at
  end
end
