# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.precompile += %w[govuk_admin_template/favicon.png]
if GovukAdminTemplate.environment_style
  Rails.application.config.assets.precompile += ["govuk_admin_template/favicon-#{GovukAdminTemplate.environment_style}.png"]
end
