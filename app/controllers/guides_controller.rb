class GuidesController < ApplicationController
  def new
  end

  def create
    guide = Guide.new
    guide.slug = params[:guide][:slug]
    guide.editions << create_edition_from_params(params[:guide][:editions])
    guide.save!
  end

  def edit
    @guide = Guide.find(params[:id])
  end

  def update
    guide = Guide.find(params[:id])
    guide.editions << create_edition_from_params(params[:guide][:edition])
  end

  private

  def create_edition_from_params hash
    edition = Edition.new

    [:title, :body].each do |a|
      edition.send("#{a}=", hash[a])
    end

    if params[:save_draft]
      edition.state = 'draft'
    elsif params[:publish]
      edition.state = 'published'
    end

    edition
  end
end
