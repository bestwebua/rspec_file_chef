module RspecFileEnv
  RSpec.describe FileChef do
    before do
      allow_any_instance_of(FileChef).to receive(:set_rspec_path).and_return(true)
      allow_any_instance_of(FileChef).to receive(:set_dir_paths).and_return(true)
    end

    describe '.config accepting' do
      let(:empty_config) do
        FileChef.config.instance_variable_get(:@config).values.all?(&:nil?)
      end

      context 'not set' do
        it 'empty config' do
          expect(empty_config).to be(true)
        end
      end

      context 'was set' do
        let(:rspec_path) { "#{File.expand_path(__dir__)}" }
        let(:custom_tmp_dir_path) { "#{rspec_path}/tmp_dir" }
        let(:custom_test_dir_path) { "#{rspec_path}/test_dir" }

        before do
          FileChef.configure do |config|
            config.rspec_path = rspec_path
            config.custom_tmp_dir = custom_tmp_dir_path
            config.custom_test_dir = custom_test_dir_path
          end
        end

        it 'not empty config' do
          expect(empty_config).to be(false)
        end

        it 'rspec_path exists' do
          expect(FileChef.config.rspec_path).to eq(rspec_path)
        end

        it 'custom_tmp_dir exists' do
          expect(FileChef.config.custom_tmp_dir).to eq(custom_tmp_dir_path)
        end

        it 'custom_test_dir exists' do
          expect(FileChef.config.custom_test_dir).to eq(custom_test_dir_path)
        end
      end
    end

    describe '#initialize' do
      describe 'method call' do
        context '#set_rspec_path' do
          specify { expect(subject.send(:set_rspec_path)).to be(true) }
        end

        context '#set_dir_paths' do
          specify { expect(subject.send(:set_dir_paths)).to be(true) }
        end
      end

      describe 'sets instance var' do
        context '@tracking_files' do
          specify { expect(subject.instance_variable_get(:@tracking_files)).to be_an_instance_of(Array) }
        end

        context '@path_table' do
          specify { expect(subject.instance_variable_get(:@path_table)).to be_an_instance_of(Hash) }
        end
      end
    end

    describe '#make' do

    end
  end
end
