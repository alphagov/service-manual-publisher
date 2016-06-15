require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  let(:commenter) do
    create(:user, name: "Commenter", email: "commenter@example.com")
  end

  let(:edition) do
    guide = create(:guide, :with_draft_edition, slug: "/service-manual/topic-name/commentable")
    guide.latest_edition
  end

  before do
    login_as commenter
  end

  describe "#create" do
    it 'redirects to a url with a unique anchor tag pointing to a comment' do
      post :create, comment: { edition_id: edition.id, comment: "LGMT!" }

      expect(response).to redirect_to(guide_editions_path(edition.guide, anchor: "comment-#{Comment.last.id}"))
    end

    it 'sends a notification email' do
      post :create, comment: { edition_id: edition.id, comment: "LGMT!" }

      expect(ActionMailer::Base.deliveries.size).to eq 1
    end

    it 'does not send a notification email if edition author is the commenter' do
      edition.update_attribute(:author, commenter)

      post :create, comment: { edition_id: edition.id, comment: "LGMT!" }

      expect(ActionMailer::Base.deliveries.size).to eq 0
    end
  end
end
