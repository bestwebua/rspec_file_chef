module RspecFileChef
  RSpec.describe TestClass do
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

      let(:regex_pattern) { subject.send(:file_pattern) }

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

    describe '#test_files' do
      specify { expect(subject.test_files).to be_an_instance_of(Array) }
    end
  end
end
