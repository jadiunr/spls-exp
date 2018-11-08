Rails.application.routes.draw do
  scope :api do
    mount_devise_token_auth_for 'User', at: 'auth', controllers: {
      registrations: 'auth/registrations'
    }
    resources :streaming_sessions
    mount ActionCable.server => '/cable'
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
