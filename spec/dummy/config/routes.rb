Rails.application.routes.draw do
  resources :users

  mount OpenStax::Utilities::Engine => "/openstax_utilities"
end
