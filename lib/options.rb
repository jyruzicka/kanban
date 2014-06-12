require "YAML"

module Options
  class << self
    def options
      @config_options ||= YAML.load_file(File.join(__dir__,"../config.yaml"))
    end

    def binary_location
      File.expand_path(options["binary_location"])
    end

    def database_location
      File.expand_path(options["database_location"])
    end

    def binary_options
      (self.options["binary_options"] || []) + ["-o", database_location]
    end

    def method_missing sym, *args
      sym_string = sym.to_s
      if args.empty? && options.has_key?(sym_string)
        options[sym_string]
      else
        super sym, *args
      end
    end
  end
end