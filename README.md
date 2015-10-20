# Service-manual-publisher

Service Manual Publisher is in very early stages and is going to be used for publishing and maintaining https://gov.uk/service-manual. This application will replace the current [service manual application](https://github.com/alphagov/government-service-design-manual).

## Screenshots

TODO

## Live examples

None at the moment.

## Nomenclature

- **Guide**: a service manual guide is the main document format used for manuals.

## Technical documentation

PostgreSQL-backed Rails 4 "Publishing 2.0" application for internal use, with no public facing aspect.

### Dependencies

- PostgreSQL
- [Publishing API](alphagov/publishing-api) - for publishing documents

### Development

`./startup.sh`

The application runs on port `3111` by default. If you're using the GDS VM it's exposed on http://service-manual-publisher.dev.gov.uk.

Currently [government-frontend](alphagov/government-frontend) has a feature flag to enable rendering service manual content.

### Seeding data

Running `bundle exec rake db:seed` will load sample data into the database.
The sample data is taken from the existing (to be deprecated)
[government-service-design-manual](https://github.com/alphagov/government-service-design-manual/) repository.
If you don't have a local clone of the
[government-service-design-manual](https://github.com/alphagov/government-service-design-manual/),
it will be cloned for you.

```
FLAG_ENABLE_SERVICE_MANUAL=1 bowl service-manual-publisher government-frontend
```

The application has a style guide that can be accessed on `/style-guide`.

### Testing

`bundle exec rspec`

## Licence

[MIT License](LICENCE)
