module RspecFileChef
  class FileChef
    include DirInitializer
    include StateKeeper
    extend Dry::Configurable
    
    setting :rspec_path
    setting :custom_tmp_dir
    setting :custom_test_dir

    def initialize(*tracking_files)
      set_rspec_path
      set_dir_paths
      @tracking_files = tracking_files
      @path_table = {}
    end

    def make
      create_path_table
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
