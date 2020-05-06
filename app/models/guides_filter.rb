class GuidesFilter
  VALID_FILTERS = %w[
    author
    content_owner
    page
    page_type
    q
    state
  ].freeze

  def initialize(scope)
    @scope = scope
    # TODO: :content_owner not being included is resulting in an N+1 query
    @scope = @scope.includes(editions: [:author]).references(:editions)
    @scope = @scope.order(updated_at: :desc)
    @scope = @scope.page(1)
  end

  def by(params)
    params.slice(*VALID_FILTERS).each do |key, param|
      next if param.blank?

      case key
      when "author"
        @scope = @scope.by_author(param)
      when "content_owner"
        @scope = @scope.owned_by(param)
      when "page"
        @scope = @scope.page(param)
      when "page_type"
        apply_type_scope(param)
      when "q"
        @scope = @scope.search(param)
      when "state"
        @scope = @scope.in_state(param)
      end
    end

    @scope
  end

private

  def apply_type_scope(type)
    @scope = case type
             when "All"
               @scope
             when "Guide"
               @scope.by_type(nil)
             else
               @scope.by_type(type)
             end
  end
end
