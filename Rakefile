# frozen_string_literal: true

require "decidim/dev/common_rake"

desc "Generates a dummy app for testing"
task test_app: "decidim:generate_external_test_app" do
  filename = File.join(Dir.pwd, "config", "civi_crm", "decidim_erc_crm_authenticable.rb")
  ENV["RAILS_ENV"] = "test"
  Dir.chdir("spec/decidim_dummy_app") do
    system("bundle exec rake decidim_erc_crm_authenticable:install:migrations")
    system("bundle exec rake db:migrate")
    dest_folder = File.join(Dir.pwd, "config", "initializers")
    FileUtils.cp(filename, dest_folder)
  end
end

namespace :civi_crm do
  desc "Configure assets required by tests"
  task configure_secrets: :environment do
    values = <<-EOVALUES
  erc_crm_authenticable:
    api_base: https://api.base/?
    site_key: site_key
    api_key: api_key
    secret_key: secret_key
    EOVALUES
    values = values.gsub("\n", "\\\n")

    cmd = "sed -i '/default: &default/a\\#{values}'  spec/decidim_dummy_app/config/secrets.yml"
    puts "---------------------------"
    puts cmd
    puts "---------------------------"
    system(cmd)
  end
end
