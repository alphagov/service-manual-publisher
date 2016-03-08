# Service-manual-publisher test!

Service Manual Publisher is in very early stages and is going to be used for publishing and maintaining https://gov.uk/service-manual. This application will replace the current [service manual application](https://github.com/alphagov/government-service-design-manual).

## Screenshots

![Landing page screenshot](http://i.imgur.com/UHqjufR.png)

![Edit interface screenshot](http://i.imgur.com/sFP1IUD.png)

## Live examples

None at the moment.

## Nomenclature

- **Guide**: a service manual guide is the main document format used for manuals.

## Technical documentation

PostgreSQL-backed Rails 4 "Publishing 2.0" application for internal use, with no public facing aspect.

### Dependencies

- [publishing-api](https://github.com/alphagov/publishing-api)
- PostgreSQL

#### Optional dependencies

**To handle image uploads**

- [asset_manager](https://github.com/alphagov/asset-manager)

**To persist and render guides**

- [content-store](https://github.com/alphagov/content-store)
- [government-frontend](https://github.com/alphagov/government-frontend)

**To index and search published guides**

- [rummager](https://github.com/alphagov/rummager)
- [designprinciples](https://github.com/alphagov/design-principles)
- [frontend](https://github.com/alphagov/frontend)

_NB: Every application above may have its own dependencies_

You will need to clone down all these repositories, and run the following commands
for each one:

```
bundle
bundle exec rake db:create
bundle exec rake db:migrate
```

### Development

To launch the application, run `./startup.sh` in the `service-manual-publisher` directory on the VM.

The application runs on port `3111` by default. If you're using the GDS VM it's exposed on http://service-manual-publisher.dev.gov.uk.

Currently [government-frontend](alphagov/government-frontend) has a feature flag to enable rendering service manual content.

```
bowl service-manual-publisher
# to run everything you might need:
# bowl service-manual-publisher government-frontend www rummager designprinciples draft-content-store router asset_manager
```

The application has a style guide that can be accessed on `/style-guide`.

### Seeding data

Running `bundle exec rake db:seed` will load sample data into the database.
The sample data is taken from the existing (to be deprecated)
[government-service-design-manual](https://github.com/alphagov/government-service-design-manual/) repository.
If you don't have a local clone of the
[government-service-design-manual](https://github.com/alphagov/government-service-design-manual/),
it will be cloned for you.

### Testing

`bundle exec rspec`

## Licence

[MIT License](LICENCE)
