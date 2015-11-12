class SlugMigrationsController < ApplicationController
  def index
    @migrations = SlugMigration.includes(:guide)
    if params[:completed].present?
      @migrations.where!(completed: params[:completed])
    end

    @completed_count = SlugMigration.where(completed: true).count
    @incompleted_count = SlugMigration.where(completed: false).count
  end

  def edit
    @slug_migration = SlugMigration.find(params[:id])
    @select_options = Guide.with_published_editions.pluck(:slug, :id)
    @selected_guide_id = @slug_migration.guide_id
  end

  def update
    @slug_migration = SlugMigration.find(params[:id])
    @select_options = Guide.with_published_editions.pluck(:slug, :id)

    guide = Guide.find_by_id(params[:slug_migration][:guide])
    @selected_guide_id = guide.try(:id)

    @slug_migration.guide = guide
    @slug_migration.completed = params[:save_and_migrate].present?

    ActiveRecord::Base.transaction do
      @slug_migration.save!

      if @slug_migration.completed?
        SlugMigrationPublisher.new.process(@slug_migration)
        redirect_to slug_migration_path(@slug_migration), notice: "Slug Migration has been completed"
      else
        redirect_to edit_slug_migration_path(@slug_migration), notice: "Slug Migration has been saved"
      end
    end
  rescue GdsApi::HTTPClientError => e
    flash[:error] = e.error_details["error"]["message"]
    render action: :edit
  rescue ActiveRecord::RecordInvalid => e
    render action: :edit
  end

  def show
    @slug_migration = SlugMigration.find(params[:id])
  end
end
