#!/usr/bin/env groovy

library("govuk")

node {
  govuk.buildProject()

  // Run against the PostgreSQL 13 Docker instance on GOV.UK CI
  govuk.setEnvar("TEST_DATABASE_URL", "postgresql://postgres@127.0.0.1:54313/service-manual-publisher_test")
}
