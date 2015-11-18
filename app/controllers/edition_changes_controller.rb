class EditionChangesController < ApplicationController
  def show
    old_edition = if params[:old_edition_id]
      Edition.find(params[:old_edition_id])
    else
      Edition.new
    end
    @edition = Edition.find(params[:new_edition_id])
    @edition_diff = EditionDiff.new(old_edition: old_edition, new_edition: @edition)
    @comments = @edition.comments.for_rendering
  end
end
