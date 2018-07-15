module RspecFileChef
  RSpec.describe TestClass do
    let(:test_examples_path)    { File.expand_path("../support/test_examples", __dir__) }
    let(:test_dir)              { "#{test_examples_path}/test_dir" }
    let(:tmp_dir)               { "#{test_examples_path}/temp_dir" }
    let(:target_dir)            { "#{test_examples_path}/target_dir" }
    let(:target_files_examples) { "#{test_examples_path}/target_files_examples" }
    let(:copy_target_files)     { FileUtils.cp_r("#{target_files_examples}/.", target_dir) }
    let(:clear_target_dir)      { FileUtils.rm_r(Dir.glob("#{target_dir}/*")) }
    let(:clear_tmp_dir)         { FileUtils.rm_r(Dir.glob("#{tmp_dir}/*")) }
    let(:regex_pattern)         { subject.send(:file_pattern) }

    let(:create_path_table) do
      copy_target_files
      allow(subject).to receive(:tracking_files).and_return(test_tracking_files)
      subject.send(:create_path_table)
    end

    let(:test_tracking_files) do
      [
       "#{test_examples_path}/target_dir/target_file_1",
       "#{test_examples_path}/target_dir/virtual_dir/target_file_2"
      ]
    end

    describe '#tracking_files' do
      specify { expect(subject.tracking_files).to be_an_instance_of(Array) }
    end

    describe '#path_table' do
      specify { expect(subject.path_table).to be_an_instance_of(Hash) }
    end

    describe '#file_pattern' do
      shared_examples(:regex_parse) do
        specify { expect(string[/#{regex_pattern}/,1]).to eq(first_group) }
        specify { expect(string[/#{regex_pattern}/,2]).to eq(second_group) }
      end

      context 'returns Regex object' do
        specify { expect(regex_pattern).to be_an_instance_of(Regexp) }
      end
      
      context 'test string 1' do
        let(:string) { '/path/file' }
        let(:first_group) { '/path' }
        let(:second_group) { 'file' }
        it_behaves_like(:regex_parse)
      end

      context 'test string 2' do
        let(:string) { '/path/path/file' }
        let(:first_group) { '/path/path' }
        let(:second_group) { 'file' }
        it_behaves_like(:regex_parse)
      end

      context 'test string 3' do
        let(:string) { '/path/file.extension' }
        let(:first_group) { '/path' }
        let(:second_group) { 'file.extension' }
        it_behaves_like(:regex_parse)
      end

      context 'test string 4' do
        let(:string) { '/path/.file' }
        let(:first_group) { '/path' }
        let(:second_group) { '.file' }
        it_behaves_like(:regex_parse)
      end

      context 'test string 5' do
        let(:string) { '/path' }
        let(:first_group) { nil }
        let(:second_group) { nil }
        it_behaves_like(:regex_parse)
      end

      context 'test string 6' do
        let(:string) { 'file' }
        let(:first_group) { nil }
        let(:second_group) { nil }
        it_behaves_like(:regex_parse)
      end

      context 'test string 7' do
        let(:string) { 'path/file.extension' }
        let(:first_group) { 'path' }
        let(:second_group) { 'file.extension' }
        it_behaves_like(:regex_parse)
      end

      context 'test string 8' do
        let(:string) { '/path/file/' }
        let(:first_group) { nil }
        let(:second_group) { nil }
        it_behaves_like(:regex_parse)
      end

      context 'test string 9' do
        let(:string) { '/path/file./' }
        let(:first_group) { nil }
        let(:second_group) { nil }
        it_behaves_like(:regex_parse)
      end
    end

    describe '#create_path_table' do
      before { create_path_table }
      after { clear_target_dir }

      shared_examples(:file_in_path_table) do
        def target_file_data(index)
          file_pattern = subject.send(:file_pattern)
          file_path = subject.tracking_files[index]
          file_name = file_path[/#{file_pattern}/,2]
          file_dir = file_path[/#{file_pattern}/,1]
          dir_exist = File.exist?(file_dir)
          [file_name, [file_path, file_dir, dir_exist]]
        end

        specify do
          expect(subject.path_table.to_a[index]).to eq(target_file_data(index))
        end
      end

      context 'path_table should be created' do
        specify { expect(subject.path_table).not_to be_empty }
      end

      context 'target file 1' do
        let(:index) { 0 }
        it_behaves_like(:file_in_path_table)
      end

      context 'target file 2' do
        let(:index) { 1 }
        it_behaves_like(:file_in_path_table)
      end
    end

    describe '#test_files' do
      before { create_path_table }
      after { clear_target_dir }
      specify { expect(subject.test_files).to be_an_instance_of(Array) }
      specify { expect(subject.test_files).to eq(%w[/target_file_1 /target_file_2]) }
    end

    describe '#move_to_tmp_dir' do
      before do
        create_path_table
        allow(subject).to receive(:tmp_dir).and_return(tmp_dir)
        subject.send(:move_to_tmp_dir)
      end

      after { clear_target_dir; clear_tmp_dir }

      let(:target_file) { 'target_file_1' }

      context 'temp dir' do
        specify { expect(Dir.entries(tmp_dir)).to include(target_file) }
      end

      context 'target dir' do
        specify { expect(Dir.entries(target_dir)).not_to include(target_file) }
      end
    end

    describe '#create_nonexistent_dirs' do
      before do
        create_path_table
        subject.send(:create_nonexistent_dirs)
      end

      after { clear_target_dir }

      specify { expect(Dir.entries(target_dir)).to include('virtual_dir') }
    end

  end
end
