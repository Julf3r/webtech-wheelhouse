class PagesController < ApplicationController
  allow_unauthenticated_access only: %i[home about visit]
  before_action :skip_authorization, only: %i[home about visit]

  def home
  end

  def services
    @services = Service.by_name
  end

  def visit
  end

  def about
  end
end
