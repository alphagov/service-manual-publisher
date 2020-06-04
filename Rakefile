# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path("config/application", __dir__)

Rails.application.load_tasks
task default: ["jasmine:ci"]

# This app needs to define a custom function/trigger, which can't
# be represented using a normal db/schema.rb file. However, using
# a db/structure.sql file is inconsistent with our other repos, as
# well as being much less readable. Instead, we primarily use the
# db/schema.rb, and load custom functionality from db/structure.sql.
Rake::Task["db:schema:load"].enhance do
  Rake::Task["db:structure:load"].invoke
end
