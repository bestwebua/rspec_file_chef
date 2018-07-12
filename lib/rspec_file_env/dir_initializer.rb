module RspecFileEnv
  module DirInitializer
    HELPER_PATH = 'support/helpers/file_chef'.freeze

    private

    def rspec_pattern
      %r{/\A.+?(?=\/spec(\/|\z))/}
    end

    def set_rspec_path
      path = FileChef.config.rspec_path
      return unless path
      path = path[/#{rspec_pattern}/]
      raise Error::RSPEC_PATH unless path
      @rspec_path = "#{path}/spec"
    end

    def custom_tmp_dir
      FileChef.config.custom_tmp_dir
    end

    def custom_test_dir
      FileChef.config.custom_test_dir
    end

    def custom_paths
      [custom_tmp_dir, custom_test_dir]
    end

    def check_config
      raise Error::CONFIG if custom_paths.any?(&:nil?)
    end

    def custom_paths_needed?
      return false if rspec_path
      check_config
      true
    end

    def check_custom_paths
      raise Error::CUSTOM_PATHS if custom_paths.any? { |path| !Dir.exist?(path) }
    end

    def create_helper_dir
      %w[temp_data test_data].map do |path|
        path = "#{rspec_path}/HELPER_PATH/#{path}"
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
