class EditionChangesController < ApplicationController
  def show
    old_edition = Edition.find(params[:old_edition_id])
    @edition = Edition.find(params[:new_edition_id])
    @edition_diff = EditionDiff.new(old_edition: old_edition, new_edition: @edition)
    @comments = @edition.comments.for_rendering
  end
end
