Rails.application.routes.draw do
  get "/healthcheck", to: GovukHealthcheck.rack_response(GovukHealthcheck::ActiveRecord)

  get "/healthcheck/live", to: proc { [200, {}, %w[OK]] }
  get "/healthcheck/ready", to: GovukHealthcheck.rack_response(
    GovukHealthcheck::ActiveRecord,
  )

  mount GovukAdminTemplate::Engine, at: "/style-guide"

  root "guides#index"

  resources :guides do
    resources :editions, only: [:index]

    member do
      get "unpublish"
      post "unpublish" => "guides#confirm_unpublish"
    end
  end

  resources :comments
  resources :uploads, only: %i[create new]
  resources :topics

  resources :slug_migrations

  get "/edition_changes(/:old_edition_id)/:new_edition_id" => "edition_changes#show", as: :edition_changes
end
