class GuidesController < ApplicationController
  def new
  end

  def create
    guide = Guide.new
    guide.slug = params[:guide][:slug]
    guide.save!
  end
end
