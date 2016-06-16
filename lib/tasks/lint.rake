desc "Run the linter"
task :lint do
  ruby_paths = "Gemfile config app spec"
  sass_paths = "app"

  if ENV["JENKINS"]
    sh "bundle exec govuk-lint-ruby --format html --out rubocop-ruby-${GIT_COMMIT}.html --format clang #{ruby_paths}"
    sh "bundle exec  govuk-lint-sass #{sass_paths}"
  else
    sh "bundle exec govuk-lint-ruby --format clang #{ruby_paths}"
    sh "bundle exec govuk-lint-sass #{sass_paths}"
  end
end

Rake::Task[:default].enhance [:lint]
