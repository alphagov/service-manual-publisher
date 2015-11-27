require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  before { login_as User.create(name: "Commenter") }

  describe "#create" do
    it 'redirects to a url with a unique anchor tag pointing to a comment' do
      edition = Generators.valid_edition
      edition.save!
      post :create, comment: { edition_id: edition.id, comment: "LGMT!" }

      expect(response).to redirect_to(edition_path(edition, anchor: "comment-#{Comment.last.id}"))
    end
  end
end
