class SlugMigrationsController < ApplicationController
  def index
    @migrations = SlugMigration.all
  end
end
