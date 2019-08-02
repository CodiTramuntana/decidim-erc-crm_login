# frozen_string_literal: true

require "rest-client"

namespace :civi_crm do
  desc ""
  task init: ["import:comarcals", "import:local_comarcal_relationships", "create:scopes"]

  namespace :import do
    desc "Generates a YAML file with the CiviCRM Contacts of type 'Organization' and sub_type 'Comarcal'"
    task :comarcals do
      response = Decidim::Erc::CrmAuthenticable::CiviCrmClient.new.find_all_comarcals
      raise "Failed to fetch the data!" if response[:is_error]

      result = response[:body].each_with_object({}) do |element, memo|
        next unless element["contact_is_deleted"].to_i.zero?

        memo[element["contact_id"].to_i] = element["display_name"]
      end

      File.write(filepath("comarcals"), result.to_yaml)
      puts "File generated 'config/civi_crm/comarcals.yml'"
    end

    desc "Generates a YAML file with the relation between CiviCRM Contacts of sub_type 'Local' and sub_type 'Comarcal'"
    task :local_comarcal_relationships do
      response = Decidim::Erc::CrmAuthenticable::CiviCrmClient.new.find_all_locals
      raise "Failed to fetch the data!" if response[:is_error]

      result = response[:body].each_with_object({}) do |element, memo|
        next unless element["contact_is_deleted"].to_i.zero?
        next unless (relationship = element["api.Relationship.get"]["values"][0])

        memo[element["contact_id"]] = relationship["contact_id_b"]
      end

      File.write(filepath("local_comarcal_relationships"), result.to_yaml)
      puts "File generated 'config/civi_crm/local_comarcal_relationships.yml'"
    end

    def filepath(filename)
      Dir.mkdir("config/civi_crm") unless File.directory?("config/civi_crm")
      Rails.root.join("config", "civi_crm", "#{filename}.yml")
    end
  end

  namespace :create do
    desc "Creates scopes"
    task scopes: :environment do
      comarcals = YAML.load_file(Rails.root.join("config", "civi_crm", "comarcals.yml"))

      comarcals.each do |contact_id, display_name|
        next if display_name[/\d/]

        organization = Decidim::Organization.first
        scope_name = display_name.remove(" (comarcal)")
        Decidim::Scope.find_or_create_by!(
          organization: organization,
          name: {"ca"=> scope_name, "en"=> scope_name, "es"=> scope_name},
          code: contact_id
        )
      end

      puts "Scopes created"
    end
  end
end
