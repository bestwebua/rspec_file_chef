module RspecFileEnv
  class FileChef
    include DirInitializer
    include StateKeeper
    extend Dry::Configurable
    
    setting :rspec_path
    setting :custom_tmp_dir
    setting :custom_test_dir

    attr_reader :tmp_dir, :test_dir, :tracking_files, :path_table, :rspec_path

    def initialize(*tracking_files)
      set_rspec_path
      set_dir_paths
      @tracking_files = tracking_files
      @path_table = {}
    end

    def make
      create_path_table
      create_test_files_list
      move_to_tmp_dir
      create_nonexistent_dirs
      copy_from_test_dir
    end

    def clear
      delete_test_files
      restore_tracking_files
      delete_nonexistent_dirs
    end
  end
end
