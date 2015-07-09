require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users, controllers: {
      registrations: 'registrations'
    }
  
  post 'dashboard/import'
  get 'dashboard/index'

  root :to => 'dashboard#index'
  get '*path' => redirect('/')

  mount Sidekiq::Web => '/sidekiq'
end
