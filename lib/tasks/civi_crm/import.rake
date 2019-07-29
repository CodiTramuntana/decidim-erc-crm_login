# frozen_string_literal: true

require "rest-client"

namespace :civi_crm do
  namespace :import do
    desc "Generates a YAML file with the CiviCRM Contacts of type 'Organization' and sub_type 'Comarcal'"
    task comarcals: :environment do
      import_contacts("Comarcal")
      puts "File generated 'config/civi_crm/comarcals.yml'"
    end

    desc "Generates a YAML file with the CiviCRM Contacts of type 'Organization' and sub_type 'Local'"
    task locals: :environment do
      import_contacts("Local")
      puts "File generated 'config/civi_crm/locals.yml'"
    end

    desc "Generates a YAML file with the CiviCRM Contacts of type 'Organization' and sub_type 'Regional'"
    task regionals: :environment do
      import_contacts("Regional")
      puts "File generated 'config/civi_crm/regionals.yml'"
    end

    desc "Generates YAML files (in 'config/civi_crm') with the CiviCRM Contacts of type 'Organization' and sub_types: 'Comarcal', 'Local' and 'Regional'"
    task all: [:comarcals, :locals, :regionals]

    private

    def import_contacts(contact_type)
      response = JSON.parse(perform_reguest(contact_type))

      result = response["values"].each_with_object({}) do |element, memo|
        next unless element["contact_is_deleted"].to_i.zero?

        memo[element["contact_id"].to_i] = element["display_name"]
      end

      File.write(filepath(contact_type), result.to_yaml)
    end

    def filepath(filename)
      Dir.mkdir('config/civi_crm') unless File.directory?('config/civi_crm')
      Rails.root.join("config", "civi_crm", "#{filename.downcase}s.yml")
    end

    def credentials
      @credentials ||= Rails.application.secrets.erc_crm_authenticable
    end

    def perform_reguest(contact_type)
      RestClient.get(credentials[:api_base] + query(contact_type))
    end

    def query(contact_type)
      {
        entity: "Contact",
        action: "get",
        api_key: credentials[:api_key],
        key: credentials[:site_key],
        json: {
          contact_type: "Organization",
          contact_sub_type: contact_type,
          sequential: 1,
          return: "contact_id,display_name",
          options: { limit: 0 }
        }.to_json
      }.map { |k, v| "#{k}=#{v}" }.join("&")
    end
  end
end
