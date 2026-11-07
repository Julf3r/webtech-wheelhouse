class CustomerPolicy < ApplicationPolicy
  def index? = user&.owner? || user&.counter?
  def show? = index?
  def new? = create?
  def create? = index?
  def edit? = update?
  def update? = index?
  def destroy? = user&.owner?

  class Scope < ApplicationPolicy::Scope
    def resolve
      user&.owner? || user&.counter? ? scope.all : scope.none
    end
  end
end