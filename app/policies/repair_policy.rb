class RepairPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user&.owner? || user&.counter? || own_repair?
  end

  def new? = create?

  def create?
    user&.owner? || user&.counter?
  end

  def edit? = update?

  def update?
    return false unless user
    return true if user.owner?
    return false if record.completed?

    user.counter? || own_repair?
  end

  def destroy?
    user&.owner?
  end

  def purge_photo?
    update? && (user.owner? || user.counter?)
  end

  def permitted_attributes
    if user&.mechanic?
      [
        :status,
        :diagnosis,
        { intake_photos: [] }
      ]
    elsif user&.owner? || user&.counter?
      [
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
        { repair_services_attributes: [[
          :id, :service_id, :charged_price, :_destroy
        ]] },
        { intake_photos: [] }
      ]
    else
      []
    end
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if user&.owner? || user&.counter?

      if user&.mechanic? && user.staff_id.present?
        scope.where(mechanic_id: user.staff_id)
      else
        scope.none
      end
    end
  end

  private

  def own_repair?
    user&.mechanic? &&
      user.staff_id.present? &&
      record.mechanic_id == user.staff_id
  end
end