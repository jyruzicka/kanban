require "YAML"

module Options
  class << self
    def config_file
      @config_file ||= File.join(__dir__,"../config.yaml")
    end

    def options
      @config_options ||= if File.exists?(config_file)
        YAML.load_file(config_file)
      else
        {}
      end
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