require "gds_api/publishing_api"
require "gds_api/content_store"

class ShortTextsController < ApplicationController
  def new
  end

  def publishing_api
    GdsApi::PublishingApi.new(Plek.new.find('publishing-api'))
  end

  def content_store
    GdsApi::ContentStore.new(Plek.new.find('content-store'))
  end

  def create
    slug = params[:short_text][:slug]
    body = params[:short_text][:body]
    title = params[:short_text][:title]

    publishing_api.put_content_item(slug, {
      publishing_app: "service-manual-publisher",
      rendering_app: "government-frontend",
      public_updated_at: Time.now,
      routes: [
        {type: "exact", path: slug}
      ],
      format: "short_text",
      title: title,
      update_type: 'minor',
    })

    redirect_to action: :show, id: slug
  end

  def show
    response = content_store.content_item(params[:id])
    @short_text = ShortText.new(response.to_hash)
  end

  def edit
  end
end
