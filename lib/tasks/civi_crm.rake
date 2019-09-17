# frozen_string_literal: true

require "rest-client"

namespace :civi_crm do
  task init: ["import:all", "create:scopes"]

  namespace :import do
    task all: [:comarcals, :local_comarcal_relationships]

    desc "Generates a YAML file with the CiviCRM Contacts of type 'Organization' and sub_type 'Comarcal'"
    task :comarcals do
      response = Decidim::Erc::CrmAuthenticable::CiviCrmClient.new.find_all_comarcals
      raise "Failed to fetch the data!" if response[:error]

      result = response[:body].each_with_object({}) do |element, memo|
        next unless element["contact_is_deleted"].to_i.zero?

        memo[element["contact_id"]] = element["display_name"]
      end

      File.write(filepath("comarcals"), result.to_yaml)
      puts "File generated 'config/civi_crm/comarcals.yml'"
    end

    desc "Generates a YAML file with the relationship between CiviCRM Contacts of sub_type 'Local' and sub_type 'Comarcal'"
    task :local_comarcal_relationships do
      response = Decidim::Erc::CrmAuthenticable::CiviCrmClient.new.find_local_comarcal_relationships
      raise "Failed to fetch the data!" if response[:error]

      comarcal_ids = YAML.load_file(Rails.root.join("config", "civi_crm", "comarcals.yml")).keys
      result = response[:body].each_with_object({}) do |element, memo|
        next unless element["contact_is_deleted"].to_i.zero?
        next unless (relationships = element["api.Relationship.get"]["values"]).any?
        next unless (comarcal_relationship = relationships.find { |r| r["contact_id_b"].in?(comarcal_ids) })

        memo[element["contact_id"]] = comarcal_relationship["contact_id_b"]
      end

      File.write(filepath("local_comarcal_relationships"), result.to_yaml)
      puts "File generated 'config/civi_crm/local_comarcal_relationships.yml'"
    end

    def filepath(filename)
      Dir.mkdir("config/civi_crm") unless File.directory?("config/civi_crm")
      Rails.root.join("config", "civi_crm", "#{filename}.yml").to_s
    end
  end

  namespace :create do
    desc "Creates `Decidim::Scope`s from the CiviCRM Contacts of type 'Organization' and sub_type 'Comarcal'"
    task scopes: :environment do
      next unless (organization = Decidim::Organization.first)

      comarcals = YAML.load_file(Rails.root.join("config", "civi_crm", "comarcals.yml"))
      comarcals.each do |contact_id, display_name|
        next if display_name[/\d/]

        scope_name = display_name.remove("(comarcal)").strip
        Decidim::Scope.find_or_create_by!(
          organization: organization,
          name: { "ca" => scope_name, "en" => scope_name, "es" => scope_name },
          code: contact_id
        )
      end

      puts "All `Decidim::Scope`s are in place"
    end
  end
end
