require 'rails_helper'

RSpec.describe Unpublish do
  describe "on create callbacks" do
    it "generates and sets content_id" do
      unpublish = Unpublish.new(content_id: nil)
      unpublish.valid?
      expect(unpublish.content_id).to be_present
    end
  end

  describe "validations" do
    it "requires presence of :old_path" do
      unpublish = Unpublish.new(old_path: nil)
      expect(unpublish).to be_invalid
      expect(unpublish.errors.full_messages_for(:old_path).size).to eq 1
    end

    it "requires presence of :new_path" do
      unpublish = Unpublish.new(new_path: nil)
      expect(unpublish).to be_invalid
      expect(unpublish.errors.full_messages_for(:new_path).size).to eq 1
    end
  end
end
