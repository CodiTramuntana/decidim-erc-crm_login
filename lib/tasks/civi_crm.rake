# frozen_string_literal: true

namespace :civi_crm do
  task init: ["import:all", "create:scopes"]

  namespace :import do
    task all: [:comarcals, :regionals, :local_comarcal_relationships, :local_regional_relationships, :decidim_scopes_mapping]

    desc "Generates a YAML file with the CiviCRM Contacts of type 'Organization' and sub_type 'Comarcal'"
    task comarcals: :environment do
      response = Decidim::Erc::CrmAuthenticable::CiviCrmClient.new.find_all_comarcals
      raise "Failed to fetch the data!" if response[:error]

      result = get_id_and_display_name(response[:body])

      File.write(filepath("comarcals"), result.to_yaml)
      puts "File generated 'config/civi_crm/comarcals.yml'"
    end

    desc "Generates a YAML file with..."
    task comarcal_exceptions: :environment do
      comarcals = YAML.load_file(Rails.root.join("config", "civi_crm", "comarcals.yml"))

      comarcal_exception_names = [
        "Baix Llobregat (comarcal)",
        "Barcelones Nord (comarcal)",
        "Maresme (comarcal)",
        "Vallès Occidental (comarcal)",
        "Vallès Oriental (comarcal)"
      ]

      result = comarcals.select{|id,name|comarcal_exception_names.include?(name)}
      raise "Comarcals not found" unless result.size == comarcal_exception_names.size

      File.write(filepath("comarcal_exceptions"), result.to_yaml)
      puts "File generated 'config/civi_crm/comarcal_exceptions.yml'"
    end

    desc "Generates a YAML file with the CiviCRM Contacts of type 'Organization' and sub_type 'Regional'"
    task regionals: :environment do
      response = Decidim::Erc::CrmAuthenticable::CiviCrmClient.new.find_all_regionals
      raise "Failed to fetch the data!" if response[:error]

      result = get_id_and_display_name(response[:body])

      File.write(filepath("regionals"), result.to_yaml)
      puts "File generated 'config/civi_crm/regionals.yml'"
    end

    desc "Generates a YAML file with the relationship between CiviCRM Contacts of sub_type 'Local' and sub_type 'Comarcal'"
    task local_comarcal_relationships: :environment do
      response = Decidim::Erc::CrmAuthenticable::CiviCrmClient.new.find_local_organization_relationships
      raise "Failed to fetch the data!" if response[:error]

      comarcal_ids = YAML.load_file(Rails.root.join("config", "civi_crm", "comarcals.yml")).keys
      result = get_id_relationships(response[:body], comarcal_ids)

      File.write(filepath("local_comarcal_relationships"), result.to_yaml)
      puts "File generated 'config/civi_crm/local_comarcal_relationships.yml'"
    end

    desc "Generates a YAML file with the relationship between CiviCRM Contacts of sub_type 'Local' and sub_type 'Regional'"
    task local_regional_relationships: :environment do
      response = Decidim::Erc::CrmAuthenticable::CiviCrmClient.new.find_local_organization_relationships
      raise "Failed to fetch the data!" if response[:error]

      regional_ids = YAML.load_file(Rails.root.join("config", "civi_crm", "regionals.yml")).keys
      result = get_id_relationships(response[:body], regional_ids)

      File.write(filepath("local_regional_relationships"), result.to_yaml)
      puts "File generated 'config/civi_crm/local_regional_relationships.yml'"
    end

    desc "Generates a YAML file with..."
    task decidim_scopes_mapping: :environment do
      comarcal_exception_ids = YAML.load_file(Rails.root.join("config", "civi_crm", "comarcal_exceptions.yml")).keys
      local_comarcal_rel = YAML.load_file(Rails.root.join("config", "civi_crm", "local_comarcal_relationships.yml"))
      local_regional_rel = YAML.load_file(Rails.root.join("config", "civi_crm", "local_regional_relationships.yml"))

      local_exception_ids = local_comarcal_rel.each_with_object([]) do |(local_id,comarcal_id), arr|
        arr << local_id if comarcal_exception_ids.include?(comarcal_id)
      end

      results = local_regional_rel.each_with_object({}) do |(local_id,regional_id), hsh|
        hsh[local_id] = local_exception_ids.include?(local_id) ? local_comarcal_rel[local_id] : regional_id
      end

      File.write(filepath("decidim_scopes_mapping"), results.to_yaml)
      puts "File generated 'config/civi_crm/decidim_scopes_mapping.yml'"
    end

    def get_id_and_display_name(body)
      body.each_with_object({}) do |element, memo|
        next unless element["contact_is_deleted"].to_i.zero?

        memo[element["contact_id"]] = element["display_name"]
      end
    end

    def get_id_relationships(body, filter_ids)
      body.each_with_object({}) do |element, memo|
        next unless element["contact_is_deleted"].to_i.zero?
        next unless (relationships = element["api.Relationship.get"]["values"]).any?
        next unless (relationship = relationships.find { |r| r["contact_id_b"].in?(filter_ids) })

        memo[element["contact_id"]] = relationship["contact_id_b"]
      end
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

      comarcals = YAML.load_file(Rails.root.join("config", "civi_crm", "comarcal_exceptions.yml"))
      comarcals.each do |contact_id, display_name|
        next if display_name[/\d/]

        scope_name = display_name.strip
        Decidim::Scope.find_or_create_by!(
          organization: organization,
          name: { "ca" => scope_name, "en" => scope_name, "es" => scope_name },
          code: contact_id
        )
      end

      regionals = YAML.load_file(Rails.root.join("config", "civi_crm", "regionals.yml"))
      regionals.each do |contact_id, display_name|
        next if display_name[/\d/]

        scope_name = display_name.strip
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
