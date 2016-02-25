class SlugMigrationsController < ApplicationController
  def index
    @migrations = SlugMigration.order(updated_at: :desc)
    if params[:completed].present?
      @migrations.where!(completed: params[:completed])
    end

    @completed_count = SlugMigration.where(completed: true).count
    @incompleted_count = SlugMigration.where(completed: false).count
  end

  def edit
    @slug_migration = SlugMigration.find(params[:id])
    @select_options = select_options
  end

  def select_options
    guide_select_options = Guide
      .with_published_editions
      .order(:slug).pluck(:slug)
      .map{|g| [g, g]}
    topic_select_options = Topic
      .order(:path).pluck(:path)
      .map{|g| [g, g]}
    {
      "Other" => ["/service-manual"],
      "Topics" => topic_select_options,
      "Guides" => guide_select_options,
    }
  end

  def update
    @slug_migration = SlugMigration.find(params[:id])
    @select_options = select_options

    slug_migration_parameters = params.require(:slug_migration)
      .permit(:redirect_to)
    slug_migration_parameters[:completed] = true

    ActiveRecord::Base.transaction do
      if @slug_migration.update_attributes(slug_migration_parameters)
        SlugMigrationPublisher.new.process(@slug_migration)
        redirect_to slug_migration_path(@slug_migration), notice: "Slug Migration has been completed"
      else
        render action: :edit
      end
    end
  rescue GdsApi::HTTPServerError => e
    flash[:error] = "An error was encountered while trying to publish the slug redirect"
    render action: :edit
  rescue GdsApi::HTTPNotFound => e
    flash[:error] = "Couldn't migrate slug because the previous slug does not exist"
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
