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

- [url-arbiter](https://github.com/alphagov/url-arbiter)
- [router-api](https://github.com/alphagov/router-api)
- [content-store](https://github.com/alphagov/content-store)
- [publishing-api](https://github.com/alphagov/publishing-api)
- PostgreSQL
- [Publishing API](https://github.com/alphagov/publishing-api) - for publishing documents

You will need to clone down all these repositories, and run the following commands
for each one:

```
bundle
bundle exec rake db:create
bundle exec rake db:migrate
```

### Development

To launch the application, run `./startup.sh` in the `service-manual-publisher` dirctory on the VM.

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
