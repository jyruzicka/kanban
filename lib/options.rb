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

    def ensure_config_exists!
      if !File.exists?(config_file)
        raise(KanbanError,
          reason: "Cannot locate config file.",
          fix:    "Ensure `config.yaml` exists. You may wish to rename `config.yaml.sample`.")
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

    def fetch_or_fail key
      if options.has_key?(key)
        options[key]
      else
        raise(KanbanError, reason: "Cannot find value for key `#{key}`", fix: "Ensure the key `#{key}` exists in `config.yaml`.")
      end
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