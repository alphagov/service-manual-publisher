class PublicationsController < ApplicationController
  def create
    @guide = Guide.find(params[:guide_id])
    ActiveRecord::Base.transaction do
      @guide.latest_edition.update_attributes!(state: 'published')
      GuidePublisher.new(guide: @guide).publish
      redirect_to @guide.latest_edition, notice: "Guide has been published"
    end

  rescue GdsApi::HTTPClientError => e
    flash[:error] = e.error_details["error"]["message"]
    @edition = @guide.latest_edition
    @comments = @edition.comments.for_rendering
    render template: 'editions/show'
  end
end
