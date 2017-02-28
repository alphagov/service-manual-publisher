# Service-manual-publisher

Service Manual Publisher is used for publishing and maintaining https://gov.uk
/service-manual. This application, together with
[service-manual-frontend](https://github.com/alphagov/service-manual-frontend)
replaced the previous Jekyll-based
[service manual](https://github.com/alphagov/government-service-design-manual).

## Screenshots

![Landing page screenshot](http://i.imgur.com/UHqjufR.png)

![Edit interface screenshot](http://i.imgur.com/sFP1IUD.png)

## Nomenclature

- **Guide**: A guide is the main document format used for manuals.
- **Guide Community**: A profile page that represents the community who curate a
  collection of guides.
- **Topic**: A collection of guides.
- **Point**: A point from the service standard.

## Technical documentation

PostgreSQL-backed Rails 4 "Publishing 2.0" application for internal use, with no
public facing aspect.

There is some [disparity between the content as it appears in the database, and
the content as it appears in the publishing api](doc/arch/002-disparity-between-database-and-publishing-api.md).
This will need to be addressed if we switch to using the publishing api as our
main data store in the future.

The Service manual's guide pages have a nested URL structure which is unusual
for GOV.UK. The pros and cons to the nested URL structure are
[retrospectively documented](doc/arch/001-nested-url-structure.md).

### Dependencies

- [publishing-api](https://github.com/alphagov/publishing-api)
- PostgreSQL

#### Optional dependencies

**To handle image uploads**

- [asset_manager](https://github.com/alphagov/asset-manager)

**To persist and render guides**

- [content-store](https://github.com/alphagov/content-store)
- [service-manual-frontend](https://github.com/alphagov/service-manual-frontend)

**To index and search published guides**

- [rummager](https://github.com/alphagov/rummager)

_NB: Every application above may have its own dependencies_

You will need to clone down all these repositories, and run the following commands
for each one:

```
bundle
bundle exec rake db:setup
```

### Development

To run the application in development you will need at least one user in the
application database. In a rails console do:

```
User.create!(name: "My Name", email: "my.email@somedomain.com")
```

You can use [Bowler](https://github.com/JordanHatch/bowler) to automatically run
the application and all of its dependencies. To do this, you'll need to check
out the [development repository](https://github.gds/gds/development) where the
`Pinfile` is located.

```
cd /var/govuk/development
bowl service-manual-publisher service-manual-frontend
```

Alternatively, run `./startup.sh` in the `service-manual-publisher` directory on
the development VM.

```
cd /var/govuk/service-manual-publisher
./startup.sh
```

The application runs on port `3111` by default. If you're using the GDS VM it's
exposed on http://service-manual-publisher.dev.gov.uk.

The application has a style guide that can be accessed on `/style-guide`.

### Testing

`bundle exec rake`

## Licence

[MIT License](LICENCE)
