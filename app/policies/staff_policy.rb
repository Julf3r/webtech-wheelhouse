class StaffPolicy < ApplicationPolicy
  def index? = user.present?
  def show? = index?
  def new? = create?
  def create? = user&.owner?
  def edit? = update?
  def update? = user&.owner?
  def destroy? = user&.owner?

  class Scope < ApplicationPolicy::Scope
    def resolve
      user.present? ? scope.all : scope.none
    end
  end
end