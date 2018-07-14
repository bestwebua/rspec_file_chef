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
      %r{\A(.+)\/(.+)\z}
    end

    def create_path_table
      tracking_files.each do |file|
        file_dir = file[/#{file_pattern}/,1]
        path_table[file[/#{file_pattern}/,2]] = [file, file_dir, File.exist?(file_dir)]
      end
    end

    def move_to_tmp_dir
      path_table.each do |_, file|
        FileUtils.mv(file[0], tmp_dir, force: true)
      end
    end

    def create_nonexistent_dirs
      path_table.each do |_, file|
        file_dir, dir_exists = file[1..-1]
        Dir.mkdir(file_dir) unless dir_exists
      end
    end

    def same_file_path(file)
      file_key = path_table[file[/#{file_pattern}/,2]]
      return file_key unless file_key
      file_key[1]
    end

    def copy_from_test_dir
      Dir.glob("#{test_dir}/*.*").each do |file|
        FileUtils.cp(file, same_file_path(file)) if same_file_path(file)
      end
    end

    def delete_test_files
      path_table.each do |_, file|
        FileUtils.rm(file[0], force: true)
      end
    end

    def restore_tracking_files
      Dir.glob("#{tmp_dir}/*.*").each do |file|
        FileUtils.mv(file, same_file_path(file), force: true)
      end
    end

    def delete_nonexistent_dirs
      path_table.each do |_, file|
        file_dir, dir_exists = file[1..-1]
        Dir.rmdir(file_dir) unless dir_exists
      end
    end
  end
end
