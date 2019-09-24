require "rails_helper"

RSpec.describe SearchHeaderPresenter do
  describe "#search" do
    it "is false if there are no search params present" do
      subject = described_class.new({ test: :test }, User.new)
      expect(subject.search?).to be false
    end

    %i[author state content_owner q].each do |search_param|
      it "is true if at least :#{search_param} param is present" do
        subject = described_class.new({ search_param.to_sym => :test }, User.new)
        expect(subject.search?).to be true
      end
    end
  end

  describe "#to_s" do
    let(:john) { User.create!(name: "John", email: "john@example.com") }

    it "starts with 'My' if the author is looking for their guides" do
      header = described_class.new({ author: john.id }, john).to_s
      expect(header).to start_with "My"
    end

    it "starts with 'Everyone's' if the author has not selected an author" do
      header = described_class.new({ author: "" }, john).to_s
      expect(header).to start_with "Everyone's"
    end

    it "starts with 'John's' if the author is looking for John's guides" do
      header = described_class.new({ author: john.id }, User.new).to_s
      expect(header).to start_with "John's"
    end

    it "humanizes the state parameter" do
      header = described_class.new({ state: "review_requested" }, User.new).to_s
      expect(header).to include "review requested guides"
    end

    it "displays the free-text query" do
      header = described_class.new({ q: "Agile Development" }, User.new).to_s
      expect(header).to include "matching \"Agile Development\""
    end

    it "appends the selected content owner" do
      community = create(:guide_community)
      header = described_class.new({ content_owner: community.id }, build(:user)).to_s
      expect(header).to end_with "published by #{community.title}"
    end
  end
end
