class GuidesController < ApplicationController
  def new
  end

  def create
    guide = Guide.new
    guide.title = params[:guide][:title]
    guide.slug = params[:guide][:slug]
    guide.save!
  end
end
