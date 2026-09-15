Rails.application.routes.draw do
  root "pages#home"

  get "services", to: "pages#services", as: :services
  get "visit", to: "pages#visit", as: :visit
  get "about", to: "pages#about", as: :about
end