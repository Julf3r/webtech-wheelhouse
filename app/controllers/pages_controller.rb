class PagesController < ApplicationController
  def home
  end

  def services
    @services = [
      { name: "Tune-up", price: 45000 },
      { name: "Wheel true", price: 18000 },
      { name: "Brake bleed", price: 25000 },
      { name: "Chain replacement", price: 15000 },
      { name: "Flat tire repair", price: 12000 },
      { name: "Brake adjustment", price: 12000 },
      { name: "Gear adjustment", price: 15000 },
      { name: "Bottom bracket service", price: 22000 },
      { name: "Headset adjustment", price: 12000 },
      { name: "Hub service", price: 20000 },
      { name: "Cable replacement", price: 10000 },
      { name: "Tubeless setup", price: 20000 }
    ]
  end

  def visit
  end

  def about
  end
end
