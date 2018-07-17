module RspecFileChef
  module StateKeeper
    attr_reader :tracking_files, :path_table

    def test_files
      path_table.map do |file_name, _|
        "#{test_dir}/#{file_name}"
      end
    end

    private

    def file_pattern
      %r{\A(.+)\/([^\/]+)\z}
    end

    def tracking_files_not_uniq?
      tracking_files != tracking_files&.uniq
    end

    def check_tracking_files
      raise 'Tracking files not unique!' if tracking_files_not_uniq?
    end

    def discover_path_depth(dir_path)
      raise 'Wrong path!' unless dir_path[/\A\//]
      paths = dir_path[1..-1].split('/').map { |item| "/#{item}" }
      paths.each_index.map { |index| paths[0..index].join }.reverse
    end

    def existing_level_depth(dir_path)
      discover_path_depth(dir_path).index { |path| Dir.exist?(path) }
    end

    def create_path_table
      tracking_files.each do |file|
        parent_dir = file[/#{file_pattern}/,1]
        status = File.exist?(parent_dir)
        level_depth = existing_level_depth(parent_dir)
        path_table[file[/#{file_pattern}/,2]] = [file, parent_dir, status, level_depth]
      end
    end

    def move_to_tmp_dir
      path_table.each do |_, file|
        FileUtils.mv(file[0], tmp_dir, force: true)
      end
    end

    def create_nonexistent_dirs
      path_table.each do |_, file|
        file_dir, dir_exists = file[1..2]
        FileUtils.mkdir_p(file_dir) unless dir_exists
      end
    end

    def same_file_path(file)
      file_key = path_table[file[/#{file_pattern}/,2]]
      return file_key unless file_key
      file_key[1]
    end

    def copy_from_test_dir
      Dir.glob("#{test_dir}/*").each do |file|
        FileUtils.cp(file, same_file_path(file)) if same_file_path(file)
      end
    end

    def delete_test_files
      path_table.each do |_, file|
        FileUtils.rm(file[0], force: true)
      end
    end

    def restore_tracking_files
      Dir.glob("#{tmp_dir}/*").each do |file|
        FileUtils.mv(file, same_file_path(file), force: true)
      end
    end

    def candidate_to_erase(file_data)
      parent_dir, level_depth = file_data[1], file_data[-1]
      level_depth-=1 unless level_depth.zero?
      discover_path_depth(parent_dir)[level_depth]
    end

    def delete_nonexistent_dirs
      path_table.each do |_, file_data|
        dir_exists = file_data[2]
        FileUtils.rm_r(candidate_to_erase(file_data)) unless dir_exists
      end
    end
  end
end
