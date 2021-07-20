Rails.application.routes.draw do
  root to: "courses#index"

  resources :courses do
    resources :documents
  end

  post "download", to: "documents#download"
end
