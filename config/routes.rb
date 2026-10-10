Rails.application.routes.draw do
  root "pages#home"

  get "visit", to: "pages#visit", as: :visit
  get "about", to: "pages#about", as: :about
  
  resources :customers
  resources :bikes
  resources :repairs
  resources :services
  resources :staff

  delete "repairs/:id/photos/:attachment_id",
       to: "repairs#purge_photo",
       as: :purge_repair_photo
end