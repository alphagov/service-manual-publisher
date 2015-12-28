require "rails_helper"

RSpec.describe NotificationMailer, type: :mailer do
  describe "#comment_added" do
    let(:gary) { Generators.valid_user(name: "Gary", email: "gary@example.com") }
    let(:luke) { Generators.valid_user(name: "Luke") }
    let(:edition) { Generators.valid_edition(title: "Agile", user: gary) }

    before do
      ActionMailer::Base.deliveries.clear
      edition.save!
      allow_any_instance_of(Edition).to receive(:notification_subscribers).and_return([gary])
    end

    it "contains the comment text, author name and a link" do
      comment = edition.comments.create!(comment: "Looking good", user: luke)

      email = NotificationMailer.comment_added(comment).deliver_now
      expect(ActionMailer::Base.deliveries.size).to eq 1
      expect(email.to).to eq ["gary@example.com"]
      expect(email.subject).to eq "New comment on \"Agile\""

      email.parts.each do |part|
        expect(part.body.to_s).to include "Luke"
        expect(part.body.to_s).to include "Looking good"
        expect(part.body.to_s).to include "edition_comments/#{edition.id}"
      end
    end
  end
end
