class SlugMigrationsController < ApplicationController
  def index
    @migrations = SlugMigration.includes(:guide)
                  .order(updated_at: :desc)
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

    slug_migration_parameters = params.require(:slug_migration)
      .permit(:guide_id)
    slug_migration_parameters[:completed] = true if params[:save_and_migrate].present?

    ActiveRecord::Base.transaction do
      if @slug_migration.update_attributes(slug_migration_parameters)
        @selected_guide_id = @slug_migration.guide.try(:id)

        if @slug_migration.completed?
          SlugMigrationPublisher.new.process(@slug_migration)
          redirect_to slug_migration_path(@slug_migration), notice: "Slug Migration has been completed"
        else
          redirect_to edit_slug_migration_path(@slug_migration), notice: "Slug Migration has been saved"
        end
      else
        render action: :edit
      end
    end
  rescue GdsApi::HTTPErrorResponse => e
    flash[:error] = e.error_details["error"]["message"]
    render action: :edit
  end

  def show
    @slug_migration = SlugMigration.find(params[:id])
  end

  def delete_search_index
    @slug_migration = SlugMigration.find(params[:slug_migration_id])
    @slug_migration.delete_search_document!

    redirect_to edit_slug_migration_path(@slug_migration), notice: "Document has been removed from search"
  end
end
