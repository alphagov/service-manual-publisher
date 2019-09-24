require "rails_helper"

RSpec.describe Redirect do
  describe "on create callbacks" do
    it "generates and sets content_id" do
      redirect = Redirect.new(content_id: nil)
      redirect.valid?
      expect(redirect.content_id).to be_present
    end
  end

  describe "validations" do
    it "requires presence of :old_path" do
      redirect = Redirect.new(old_path: nil)
      expect(redirect).to be_invalid
      expect(redirect.errors.full_messages_for(:old_path).size).to eq 1
    end

    it "requires presence of :new_path" do
      redirect = Redirect.new(new_path: nil)
      expect(redirect).to be_invalid
      expect(redirect.errors.full_messages_for(:new_path).size).to eq 1
    end
  end
end
