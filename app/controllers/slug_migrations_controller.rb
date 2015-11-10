class SlugMigrationsController < ApplicationController
  def index
    @migrations = SlugMigration.all
    if params[:completed].present?
      @migrations = @migrations.where(completed: params[:completed])
    end
  end

  def edit
    @slug_migration = SlugMigration.find(params[:id])
    @select_options = Guide.joins(:editions).where(editions: { state: "published" })
                        .map {|g| [g.slug, g.id] }
    @selected_guide_id = @slug_migration.guide.try(:id)
  end

  def update
    slug_migration = SlugMigration.find(params[:id])
    guide = Guide.find(params[:slug_migration][:guide])
    slug_migration.guide = guide
    slug_migration.save!
    redirect_to edit_slug_migration_path(slug_migration), notice: "Slug Migration has been updated"
  end
end
