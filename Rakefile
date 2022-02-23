# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path("config/application", __dir__)

Rails.application.load_tasks

desc "Jasmine"
task :jasmine do
  sh "yarn run jasmine:ci"
end

# RSpec shoves itself into the default task without asking, which confuses the ordering.
# https://github.com/rspec/rspec-rails/blob/eb3377bca425f0d74b9f510dbb53b2a161080016/lib/rspec/rails/tasks/rspec.rake#L6
Rake::Task[:default].clear if Rake::Task.task_defined?(:default)
task default: %i[lint spec jasmine]

# This app needs to define a custom function/trigger, which can't
# be represented using a normal db/schema.rb file. However, using
# a db/structure.sql file is inconsistent with our other repos, as
# well as being much less readable. Instead, we primarily use the
# db/schema.rb, and load custom functionality from db/custom_functions.sql.
%w[db:schema:load db:test:prepare].each do |task|
  Rake::Task[task].enhance do
    # Additionally load db/custom_functions.sql
    ActiveRecord::Tasks::DatabaseTasks.load_schema_current(:sql, "db/custom_functions.sql")
  end
end
