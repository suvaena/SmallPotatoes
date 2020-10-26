Rails.application.routes.draw do
  get 'movies/index'
  post 'movies/create'
  get 'movies/new'
  get 'movies/edit'
  get 'movies/show'
  get 'movies/update'
  get 'movies/destroy'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
    resources :movies
end