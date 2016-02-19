require 'rails_helper'

RSpec.describe Publisher, '#save_draft' do
  it 'persists the content model' do
    guide = Generators.valid_guide

    Publisher.new(content_model: guide).save_draft

    expect(guide).to be_persisted
  end
end
