Rails.application.routes.draw do
  break if ENV["RAILS_PRECOMPILE"]

  get "/_health", to: proc { [200, {}, ["OK"]] }

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  devise_scope :user do
    get "login", :to => "devise/sessions#new", :as => :new_user_session
    delete "logout", :to => "devise/sessions#destroy", :as => :destroy_user_session
  end

  get "/attachments/*rest", :to => "attachments#download"

  resources :uploads, :only => [:index, :create, :destroy]

  resources :photos, :only => [] do
    member do
      get "download"
    end
  end

  resources :reports do
    member do
      get "download"
    end
  end

  root :to => "reports#index"
end
