require 'rails_helper'

RSpec.describe Edition, type: :model do
  describe "validations" do
    it "requires user to be present" do
      edition = Generators.valid_edition(user: nil)
      expect(edition).to be_invalid
      expect(edition.errors.full_messages_for(:user).size).to eq 1
    end

    it "allows 'published' state" do
      edition = Generators.valid_published_edition
      edition.valid?
      expect(edition.errors.full_messages_for(:state).size).to eq 0
    end

    valid_states = %w(draft review_requested approved)
    valid_states.each do |valid_state|
      it "allows '#{valid_state}' state" do
        edition = Generators.valid_edition(state: valid_state)
        edition.valid?
        expect(edition.errors.full_messages_for(:state).size).to eq 0
      end
    end

    it "does not allow arbitrary values" do
      edition = Generators.valid_edition(state: 'invalid state')
      edition.valid?
      expect(edition.errors.full_messages_for(:state).size).to eq 1
    end
  end

  describe "#copyable_attributes" do
    it "returns a hash with attributes excluding fields that get populated on save" do
      saved_edition = Generators.valid_edition
      saved_edition.save!

      attributes = saved_edition.copyable_attributes

      expect(attributes['title']).to eq saved_edition.title
      expect(attributes['body']).to eq saved_edition.body

      expect(attributes['id']).to eq nil
      expect(attributes['created_at']).to eq nil
      expect(attributes['updated_at']).to eq nil
    end

    it "allows to add/override attributes" do
      edition = Generators.valid_edition
      edition.state = 'draft'
      attributes = edition.copyable_attributes(state: 'published', title: 'Teams')

      expect(attributes['title']).to eq 'Teams'
      expect(attributes['state']).to eq 'published'
    end
  end

  describe "#unsaved_copy" do
    it "returns a copy without fields that get populated on save" do
      saved_edition = Generators.valid_edition
      saved_edition.save!

      unsaved = saved_edition.unsaved_copy

      expect(unsaved.title).to eq saved_edition.title
      expect(unsaved.body).to eq saved_edition.body

      expect(unsaved).to be_a_new_record
      expect(unsaved.id).to eq nil
      expect(unsaved.created_at).to eq nil
      expect(unsaved.updated_at).to eq nil
    end
  end
end
