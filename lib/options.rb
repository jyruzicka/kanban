require "YAML"

module Options
  def self.options
    @config_options ||= YAML.load_file(File.join(__dir__,"../config.yaml"))
  end

  def self.binary_location
    File.expand_path(options["binary_location"])
  end

  def self.database_location
    File.expand_path(options["database_location"])
  end

  def self.binary_options
    (self.options["binary_options"] || []) + ["-o", database_location]
  end
end