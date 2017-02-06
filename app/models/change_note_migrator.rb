class ChangeNoteMigrator
  def initialize(dry_run: true, publishing_api: PUBLISHING_API)
    @dry_run = dry_run
    @publishing_api = publishing_api
  end

  def update_change_note(edition_id, change_note)
    transaction do
      edition = load_edition(edition_id)
      update_edition(edition, change_note: change_note)
      publish!(edition)
    end
  end

  def make_minor(edition_id)
    transaction do
      edition = load_edition(edition_id)
      update_edition(edition, update_type: 'minor')
      publish!(edition)
    end
  end

  def make_major(edition_id, change_note)
    transaction do
      edition = load_edition(edition_id)
      update_edition(edition, update_type: 'major', change_note: change_note)
      publish!(edition)
    end
  end

private

  attr_reader :dry_run, :publishing_api

  def load_edition(edition_id)
    Edition.published.find(edition_id).tap do |e|
      log "Loaded edition with ID #{e.id} (version #{e.version} of #{e.guide.slug})", :green
    end
  end

  def update_edition(edition, changes)
    log_changes(edition, changes)

    return if dry_run
    log "  Updating database"
    edition.assign_attributes(changes)
    if edition.validate && edition.errors.any? { |e| changes.keys.map(&:to_s).include?(e.first.to_s) }
      edition.validate!
    end
    edition.save!(validate: false)
    log "  Database updated", :bold
  end

  def log_changes(edition, changes)
    log "  Change summary:"
    no_changes = edition
                  .attributes
                  .select { |k, _| changes.keys.map(&:to_s).include?(k) }
                  .select { |k, v| changes.with_indifferent_access[k] != v }
                  .each { |k, v| log "  Old value of #{k} is #{v}, new value is #{changes.with_indifferent_access[k]}", :yellow }
                  .empty?

    log "  Nothing to change", :yellow if no_changes
  end

  def publish!(edition)
    return if dry_run
    log "  Updating Publishing API"
    GuideRepublisher.new(edition.guide, publishing_api: publishing_api).republish
    log "  Publishing API updated", :bold
  end

  def log(line, *colors)
    return if Rails.env.test?
    @_cli ||= HighLine.new
    @_cli.say(@_cli.color(line, *colors))
  end

  def transaction
    ApplicationRecord.transaction do
      yield
    end
  rescue => e
    log "  #{e.class}: #{e.message}", :red
    log "  No database changes made, check state of Publishing API", :bold unless dry_run
    raise
  end
end
