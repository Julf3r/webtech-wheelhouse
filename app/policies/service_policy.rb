class ServicePolicy < ApplicationPolicy
    def index? = true
    def show? = true
    def new? = create?
    def create? = user&.owner?
    def edit? = update?
    def update? = user.owner?
    def destroy? = user.owner?

    class Scope < ApplicationPolicy::Scope
        def resolve = scope.all
    end
end