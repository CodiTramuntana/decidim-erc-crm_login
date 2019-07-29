# frozen_string_literal: true

namespace :decidim do
  desc "Installs migration to the dummy test app."
  task :update_test_app do
    Dir.chdir("spec/decidim_dummy_app")

    `bin/rails generate migration AddScopeToDecidimUsers decidim_scope_id:integer`
    puts "\nGenerated migration add_scope_to_decidim_users.rb"

    sleep 2

    `bin/rails db:migrate`
    puts "\n========== AddScopeToDecidimUsers: migrated =========="
    puts "add_column(:decidim_users, :decidim_scope_id, :integer"
  end
end
