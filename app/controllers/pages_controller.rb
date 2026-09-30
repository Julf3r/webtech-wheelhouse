class PagesController < ApplicationController
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
