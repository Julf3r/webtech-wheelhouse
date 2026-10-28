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

  namespace :api do
    namespace :v1 do
      resources :services, only: %i[index show create]
      resources :repairs, only: %i[index show]
    end
  end
end