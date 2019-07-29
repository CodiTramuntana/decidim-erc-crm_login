# frozen_string_literal: true

require 'decidim/dev/common_rake'
load './lib/tasks/decidim_tasks.rake'

desc 'Generates a dummy app for testing'
task :test_app do
  Rails.env = "test"
  Rake::Task['decidim:generate_external_test_app'].invoke
  Rake::Task['decidim:update_test_app'].invoke
end
