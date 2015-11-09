class SlugMigrationsController < ApplicationController
  def index
    @migrations = SlugMigration.all
    if params[:completed].present?
      @migrations = @migrations.where(completed: params[:completed])
    end
  end
end
