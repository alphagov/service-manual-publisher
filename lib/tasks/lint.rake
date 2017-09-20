desc "Run the linter"
task :lint do
  sh "bundle exec govuk-lint-ruby --diff --cached --format clang app lib spec test"
  sh "bundle exec govuk-lint-sass app"
end
