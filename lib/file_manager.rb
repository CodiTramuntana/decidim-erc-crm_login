# frozen_string_literal: true

module FileManager
  def write_config_yaml!(filename, content)
    File.write(filepath(filename), content.to_yaml)
    puts "File generated 'config/civi_crm/#{filename}.yml'"
  end

  def filepath(filename)
    Dir.mkdir("config/civi_crm") unless File.directory?("config/civi_crm")
    Rails.root.join("config", "civi_crm", "#{filename}.yml").to_s
  end

  def load_config_yaml(filename)
    YAML.load_file(filepath(filename))
  end
end
