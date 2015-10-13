class GuidesController < ApplicationController
  def new
  end

  def create
    guide = Guide.new
    guide.slug = params[:guide][:slug]

    edition = Edition.new
    [:title, :body].each do |a|
      edition.send("#{a}=", params[:guide][:editions][a])
    end

    if params[:save_draft]
      edition.state = "draft"
    elsif params[:publish]
      edition.state = "published"
    end

    guide.editions << edition

    guide.save!
  end

  def edit
    @guide = Guide.find(params[:id])
  end

  def update
    guide = Guide.find(params[:id])
    edition = Edition.new
    [:title, :body].each do |a|
      edition.send("#{a}=", params[:guide][:edition][a])
    end
    if params[:save_draft]
      edition.state = "draft"
    elsif params[:publish]
      edition.state = "published"
    end
    guide.editions << edition
  end
end
