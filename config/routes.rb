require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users, controllers: {
      registrations: 'registrations'
    }
  
  post 'dashboard/import'
  get 'dashboard/index'
  match 'dashboard/search', via: [:get, :post]

  root :to => 'dashboard#index'

  mount Sidekiq::Web => '/sidekiq'
  get '*path' => redirect('/')
end
