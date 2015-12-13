CampusCodefest::Application.routes.draw do
  # Non-org routes
  root :to => "home#index", constraints: lambda { |r| !r.subdomain.present? || r.subdomain == 'www' }
  get "about" => "home#about", constraints: lambda { |r| !r.subdomain.present? || r.subdomain == 'www' }
  get "faq" => "home#faq", constraints: lambda { |r| !r.subdomain.present? || r.subdomain == 'www' }
  get "github" => "home#github", constraints: lambda { |r| !r.subdomain.present? || r.subdomain == 'www' }

  # Shared routes
  resources :organizations

  resources :users do
    member do
      get :confirm_email
      post :deactivate
      get :set_email
    end
  end
  resource :session

  namespace :super_admin do
    root to: "home#index"
    resources :users do
      collection do
        get :search
      end
    end

    resources :organizations do
      collection do
        get :search
      end
    end
  end

  get 'contact' => 'contact#new', :as => 'contact'
  post 'contact' => 'contact#create', :as => 'contact_create'

  get "/auth/:provider/callback" => "sessions#create"
  get "/signout" => "sessions#signout", :as => :signout

  # Organization routes
  get '/', :to => "organization_home#index", constraints: lambda { |r| r.subdomain.present? && r.subdomain != 'www' }
  get "unverified" => "organization_home#unverified", constraints: lambda { |r| r.subdomain.present? && r.subdomain != 'www' }

  resources :events, constraints: lambda { |r| r.subdomain.present? && r.subdomain != 'www' } do
    resources :event_registrations
    resource :dashboard
    resources :event_comments
  end

  resources :invitations, constraints: lambda { |r| r.subdomain.present? && r.subdomain != 'www' } do
    member do
      put :accept
      put :decline
    end
  end

  resource :organization_users, only: [:create]#, constraints: lambda { |r| r.subdomain.present? && r.subdomain != 'www' }

  resources :projects, constraints: lambda { |r| r.subdomain.present? && r.subdomain != 'www' } do
    member do
      post :rate
      post :volunteer
      post :unvolunteer
    end

    resources :project_comments
    resource :presentation do
      collection do
        post :publish
      end
    end
  end

  namespace :admin, constraints: lambda { |r| r.subdomain.present? && r.subdomain != 'www' } do
    root :to => 'home#index'
    resource :organization do
      resources :invitations
    end

    resources :users do
      collection do
        get :search
      end

      member do
        put :canonize
        put :verify
      end
    end

    resources :events do
      resources :event_moderators
      resources :event_registrations
      resources :builder
      resources :invitations, controller: "event_invitations"

      resources :projects do
        resources :project_volunteers
        resources :project_comments
        resources :project_votes
      end

    end

    resources :projects
    resources :after_create
  end
end
