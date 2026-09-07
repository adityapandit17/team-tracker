Rails.application.routes.draw do
  devise_for :users, skip: [:registrations]
  as :user do
    get "users/edit" => "devise/registrations#edit", as: :edit_user_registration
    put "users" => "devise/registrations#update", as: :user_registration
    patch "users" => "devise/registrations#update", as: nil
  end

  root "dashboard#index"

  get "/users", to: redirect("/accounts")

  resources :accounts, controller: "users", except: [:show] do
    member do
      post :demote
    end
  end

  resources :developers do
    member do
      post :promote
    end
    resources :feedbacks, only: %i[index new create]
    resources :assessments, only: %i[index new create]
    resources :action_items, only: %i[index new create]
    resources :one_on_ones, only: %i[index new create]
    resources :growth_plans, only: %i[index new create]
    resources :allocations, only: %i[index new create]
  end
  resources :projects do
    member do
      patch :update_cell
    end
    resources :project_billings, path: "billings", except: [:show] do
      member do
        post :clear
        post :reopen
        post :submit
      end
    end
    resources :allocations, only: %i[index new create]
  end

  resources :billings, only: [:index]
  resources :utilization, only: [:index]
  resources :incentives, only: %i[index show]
  resources :audits, only: [:index]
  get "hierarchy", to: "hierarchy#index", as: :hierarchy

  resources :skills, only: [:index]
  patch "skills/update_cell", to: "skills#update_cell", as: :update_skill_cell
  resources :client_leads

  resources :feedbacks
  resources :assessments
  resources :action_items do
    member do
      patch :update_status
    end
  end
  resources :one_on_ones
  resources :growth_plans
  resources :allocations
  get "bench", to: "allocations#bench", as: :bench

  get "up" => "rails/health#show", as: :rails_health_check
end
