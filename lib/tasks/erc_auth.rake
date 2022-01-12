# frozen_string_literal: true

require "csv"
require "file_manager"

namespace :erc_auth do
  include FileManager

  namespace :csv_import do
    task all: [:comarcals, :regionals, :locals, :local_comarcal_relationships, :local_regional_relationships]

    desc "Generates a YAML file with the CSV with 'Comarcal' tag"
    task comarcals: :environment do
      csv_text = File.read("tmp/scopes_codes.csv")
      csv = CSV.parse(csv_text, headers: true)

      csv = csv.select { |row| row["type"] == "FC" }
      csv = csv.map(&:to_h)

      result = get_code_and_display_name(csv)
      write_config_yaml!("comarcals", result)
    end

    desc "Generates a YAML file with the CSV with 'Regional' tag"
    task regionals: :environment do
      csv_text = File.read("tmp/scopes_codes.csv")
      csv = CSV.parse(csv_text, headers: true)

      csv = csv.select { |row| row["type"] == "FR" }
      csv = csv.map(&:to_h)

      result = get_code_and_display_name(csv)
      write_config_yaml!("regionals", result)
    end

    desc "Generates a YAML file with the CSV with 'Locals' tag"
    task locals: :environment do
      csv_text = File.read("tmp/scopes_codes.csv")
      csv = CSV.parse(csv_text, headers: true)

      csv = csv.select { |row| row["type"] == "SL" }
      csv = csv.map(&:to_h)

      result = get_code_and_display_name(csv)
      write_config_yaml!("locals", result)
    end

    desc "Generates a YAML file with the relationship between CSV 'Local' and 'Comarcal'"
    task local_comarcal_relationships: :environment do
      local_ids = load_config_yaml("locals").keys
      comarcal_ids = load_config_yaml("comarcals").keys
      result = get_code_relationships(local_ids, comarcal_ids, "comarcal")
      write_config_yaml!("local_comarcal_relationships", result)
    end

    desc "Generates a YAML file with the relationship between CSV 'Local' and 'Regional'"
    task local_regional_relationships: :environment do
      local_ids = load_config_yaml("locals").keys
      regional_ids = load_config_yaml("regionals").keys
      result = get_code_relationships(local_ids, regional_ids, "regional")
      write_config_yaml!("local_regional_relationships", result)
    end

    def get_code_and_display_name(body)
      body.map! { |element| { element["code"] => element["name"] } }.reduce({}, :merge)
    end

    def get_code_relationships(local_ids, _filter_ids, scope_type)
      local_ids.each_with_object({}) do |element, memo|
        csv_text = File.read("tmp/scopes_hierarchy.csv")
        csv = CSV.parse(csv_text, headers: true)

        csv = csv.select { |row| row["SL"] == element }.first.to_h
        next if csv.blank?

        case scope_type
        when "comarcal"
          memo[csv["SL"]] = csv["FC"]
        when "regional"
          memo[csv["SL"]] = csv["FR"]
        end
      end
    end
  end
end
