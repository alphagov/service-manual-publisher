#!/usr/bin/env groovy

REPOSITORY = 'service-manual-publisher'

// @todo Replace with govuk.setupDb when on Rails 5.
// (govuk.setupDb runs bundle exec *rails* db:drop etc)
def setupDb() {
  echo 'Setting up database'
  sh('RAILS_ENV=test bundle exec rake db:drop db:create db:structure:load')
}

node {
  // Deployed by Puppet's Govuk_jenkins::Pipeline manifest
  def govuk = load '/var/lib/jenkins/groovy_scripts/govuk_jenkinslib.groovy'

  properties([
    buildDiscarder(
      logRotator(
        numToKeepStr: '50')
      ),
    [$class: 'RebuildSettings', autoRebuild: false, rebuildDisabled: false],
    [$class: 'ThrottleJobProperty',
      categories: [],
      limitOneJobWithMatchingParams: true,
      maxConcurrentPerNode: 1,
      maxConcurrentTotal: 0,
      paramsToUseForLimit: REPOSITORY,
      throttleEnabled: true,
      throttleOption: 'category'],
  ])

  try {
    stage("Build") {
      checkout scm

      govuk.cleanupGit()
      govuk.mergeMasterBranch()

      govuk.setEnvar("RAILS_ENV", "test")
      govuk.bundleApp()

      setupDb()
      
      govuk.contentSchemaDependency()
      govuk.setEnvar("GOVUK_CONTENT_SCHEMAS_PATH", "tmp/govuk-content-schemas")

      govuk.precompileAssets()
    }

    stage("Lint") {
      govuk.rubyLinter()
    }

    stage("Test") {
      sh("bundle exec rspec --format documentation")
    }

    stage("Deploy") {
      // pushTag and deployIntegration are no-ops unless on master branch
      govuk.pushTag(REPOSITORY, env.BRANCH_NAME, 'release_' + env.BUILD_NUMBER)
      govuk.deployIntegration(REPOSITORY, env.BRANCH_NAME, 'release', 'deploy')
    }

  } catch (e) {
    currentBuild.result = "FAILED"
    step([$class: 'Mailer',
          notifyEveryUnstableBuild: true,
          recipients: 'govuk-ci-notifications@digital.cabinet-office.gov.uk',
          sendToIndividuals: true])
    throw e
  }
}
