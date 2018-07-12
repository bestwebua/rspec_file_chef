module RspecFileEnv
  module DirInitializer
    private

    def rspec_pattern
      %r{/\A.+?(?=\/spec(\/|\z))/}
    end

    def set_rspec_path
      path = FileChef.config.rspec_path
      return unless path
      path = path[/#{rspec_pattern}/]
      raise 'Wrong rspec path.' unless path
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
      error = 'Config error. You should specify custom tmp_dir and test_dir params.'
      raise error if custom_paths.any?(&:nil?)
    end

    def custom_paths_needed?
      return false if rspec_path
      check_config
      true
    end

    def check_custom_paths
      error = 'All custom paths should exist.'
      raise error if custom_paths.any? { |path| !Dir.exist?(path) }
    end

    def create_helper_dir
      support_path = "#{rspec_path}/support/helpers/file_chef"
      %w[temp_data test_data].map do |path|
        path = "#{support_path}/#{path}"
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
