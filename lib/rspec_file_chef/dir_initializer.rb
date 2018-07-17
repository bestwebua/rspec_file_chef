module RspecFileChef
  module DirInitializer
    HELPER_PATH = 'support/helpers/file_chef'.freeze

    attr_reader :tmp_dir, :test_dir, :rspec_path

    private

    def rspec_pattern
      %r{\A.+?(?=\/spec(\/|\z))}
    end

    def default_rspec_path
      self.class.config.rspec_path
    end

    def custom_tmp_dir
      self.class.config.custom_tmp_dir
    end

    def custom_test_dir
      self.class.config.custom_test_dir
    end

    def set_rspec_path
      return unless default_rspec_path
      path = default_rspec_path[/#{rspec_pattern}/]
      raise Error::RSPEC_PATH unless path
      @rspec_path = "#{path}/spec"
    end

    def custom_paths
      [custom_tmp_dir, custom_test_dir]
    end

    def any_custom_path(&block)
      custom_paths.any?(&block)
    end

    def not_exist?
      lambda { |path| !Dir.exist?(path) }
    end

    def check_config
      raise Error::CONFIG if any_custom_path(&:nil?)
      true
    end

    def custom_paths_needed?
      return false if rspec_path
      check_config
    end

    def check_custom_paths
      raise Error::CUSTOM_PATHS if any_custom_path(&not_exist?)
    end

    def create_helper_dir
      %w[temp_data test_data].map do |path|
        path = "#{rspec_path}/#{HELPER_PATH}/#{path}"
        FileUtils.mkdir_p(path)
        path
      end
    end

    def set_dir_paths
      @tmp_dir, @test_dir =
        if custom_paths_needed?
          check_custom_paths
          custom_paths
        else
          create_helper_dir
        end
    end
  end
end
