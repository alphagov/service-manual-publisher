require 'rails_helper'

RSpec.describe SearchHeaderPresenter do
  describe "#search" do
    it "is false if there are no search params present" do
      subject = described_class.new({ test: :test }, User.new)
      expect(subject.search?).to be false
    end

    [:user, :state, :content_owner, :q].each do |search_param|
      it "is true if at least :#{search_param} param is present" do
        subject = described_class.new({ search_param.to_sym => :test }, User.new)
        expect(subject.search?).to be true
      end
    end
  end

  describe "#to_s" do
    let(:john) { User.create!(name: "John", email: "john@example.com") }

    it "starts with 'My' if the user is looking for their guides" do
      header = described_class.new({ user: john.id }, john).to_s
      expect(header).to start_with "My"
    end

    it "starts with 'Everyone's' if the user has not selected an author" do
      header = described_class.new({ user: "" }, john).to_s
      expect(header).to start_with "Everyone's"
    end

    it "starts with 'John's' if the user is looking for John's guides" do
      header = described_class.new({ user: john.id }, User.new).to_s
      expect(header).to start_with "John's"
    end

    it "humanizes the state parameter" do
      header = described_class.new({ state: 'review_requested' }, User.new).to_s
      expect(header).to include "review requested guides"
    end

    it "displays the free-text query" do
      header = described_class.new({ q: 'Agile Development' }, User.new).to_s
      expect(header).to include "matching \"Agile Development\""
    end

    it "appends the selected content owner" do
      agile_community = Guide.create!(
        community: true,
        latest_edition: Generators.valid_edition(title: "Agile Community"),
        slug: "/service-manual/agile-community"
      )

      header = described_class.new({ content_owner: agile_community.id }, User.new).to_s
      expect(header).to end_with "published by Agile Community"
    end
  end
end
