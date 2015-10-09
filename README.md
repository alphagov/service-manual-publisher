# Service-manual-publisher

This application allows editing of service manual pages.

## Screenshots

## Live examples (if available)

- [gov.uk/thing](https://www.gov.uk/thing)

### Dependencies

- [alphagov/government-frontend]() - for rendering service manual pages on gov.uk
- [postgresql]() - for the db

### Running the application

Currently `government-frontend` has a feature flag to enable service manual
content.

`FLAG_ENABLE_SERVICE_MANUAL=1 bowl service-manual-publisher government-frontend`
`./startup.sh`

The app should now appear on http://service-manual-publisher.dev.gov.uk

### Running the test suite

`bundle exec rake`

## Licence

[MIT License](LICENCE)
