require "rails_helper"

RSpec.describe EditionDiff, type: :model do
  describe "#changes" do
    it "returns the original text without markup if no change detected" do
      diff = described_class.new(
        new_edition: Edition.new(title: "Hello"),
        old_edition: Edition.new(title: "Hello"),
      )

      expect(diff.changes[:title].diff).to eq "Hello"
    end

    it "returns a marked up text difference" do
      edition_diff = described_class.new(
        new_edition: Edition.new(title: "Bye"),
        old_edition: Edition.new(title: "Hello"),
      )

      diff_markup = edition_diff.changes[:title].diff
      expect(diff_markup).to include "<ins><span class=\"symbol\">+</span><strong>Bye</strong></ins>"
      expect(diff_markup).to include "<del><span class=\"symbol\">-</span><strong>Hello</strong></del>"
    end
  end
end
