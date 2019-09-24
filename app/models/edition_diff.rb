class EditionDiff
  TRACKABLE_FIELDS = [:title, :content_owner_title, :description, :body].freeze

  attr_reader :old_edition, :new_edition

  def initialize(new_edition:, old_edition:)
    @new_edition = new_edition
    @old_edition = old_edition
  end

  def changes
    field_changes =
      TRACKABLE_FIELDS.inject({}) do |memo, field|
        old_text = old_edition.public_send(field).to_s
        new_text = new_edition.public_send(field).to_s
        memo[field] = FieldChange.new(
          old_text: old_text,
          new_text: new_text,
          field: field,
        )
        memo
      end
    field_changes.with_indifferent_access
  end

  class FieldChange
    attr_reader :old_text, :new_text

    def initialize(old_text:, new_text:, field:)
      @old_text = old_text
      @new_text = new_text
      @field = field.to_s
    end

    def diff
      diff = Diffy::Diff.new(old_text, new_text, allow_empty_diff: true, include_plus_and_minus_in_html: true)
      if diff.any?
        diff.to_s(:html).html_safe
      else
        new_text
      end
    end

    def field_name
      @field.titleize
    end
  end
end
