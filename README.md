# Service Manual Publisher

Service Manual Publisher is used for publishing and maintaining https://www.gov.uk/service-manual. This application, together with [Service Manual Frontend](https://github.com/alphagov/service-manual-frontend) replaced the previous [Jekyll-based service manual](https://github.com/alphagov/government-service-design-manual).

## Nomenclature

- **Guide**: A guide is the main document format used for manuals.
- **Guide Community**: A profile page that represents the community who curate a collection of guides.
- **Topic**: A collection of guides.
- **Point**: A point from the service standard.

## Technical documentation

This is a Ruby on Rails app, and should follow [our Rails app conventions](https://docs.publishing.service.gov.uk/manual/conventions-for-rails-applications.html).

There is some [disparity between the content as it appears in the database, and the content as it appears in the publishing api](docs/arch/002-disparity-between-database-and-publishing-api.md). This will need to be addressed if we switch to using the Publishing API as our main data store in the future.

The Service manual's guide pages have a nested URL structure which is unusual for GOV.UK. The pros and cons to the nested URL structure are [retrospectively documented](docs/arch/001-nested-url-structure.md).

You can use the [GOV.UK Docker environment](https://github.com/alphagov/govuk-docker) to run the application and its tests with all the necessary dependencies. Follow [the usage instructions](https://github.com/alphagov/govuk-docker#usage) to get started.

**Use GOV.UK Docker to run any commands that follow.**

### Running the test suite

```sh
bundle exec rake
```

## Licence

[MIT License](LICENCE)
