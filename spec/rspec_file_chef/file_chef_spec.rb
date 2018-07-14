module RspecFileChef
  RSpec.describe FileChef do
    before do
      allow_any_instance_of(FileChef).to receive(:set_rspec_path).and_return(true)
      allow_any_instance_of(FileChef).to receive(:set_dir_paths).and_return(true)
    end

    shared_examples(:method_call) do
      specify { expect(subject.send(method)).to be(true) }
    end

    describe '.config accepting' do
      let(:empty_config) do
        subject.class.config.instance_variable_get(:@config).values.all?(&:nil?)
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
          subject.class.configure do |config|
            config.rspec_path = rspec_path
            config.custom_tmp_dir = custom_tmp_dir_path
            config.custom_test_dir = custom_test_dir_path
          end
        end

        it 'not empty config' do
          expect(empty_config).to be(false)
        end

        it 'rspec_path exists' do
          expect(subject.class.config.rspec_path).to eq(rspec_path)
        end

        it 'custom_tmp_dir exists' do
          expect(subject.class.config.custom_tmp_dir).to eq(custom_tmp_dir_path)
        end

        it 'custom_test_dir exists' do
          expect(subject.class.config.custom_test_dir).to eq(custom_test_dir_path)
        end
      end
    end

    describe '#initialize' do
      describe 'method call' do
        context '#set_rspec_path' do
          let(:method) { :set_rspec_path }
          it_behaves_like(:method_call)
        end

        context '#set_dir_paths' do
          let(:method) { :set_dir_paths }
          it_behaves_like(:method_call)
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
      let(:instance_methods) do
        %i[create_path_table move_to_tmp_dir create_nonexistent_dirs copy_from_test_dir]
      end

      before do
        instance_methods.each do |method|
          allow_any_instance_of(FileChef).to receive(method).and_return(true)
        end
      end

      describe 'method call' do
        context '#create_path_table' do
          let(:method) { :create_path_table }
          it_behaves_like(:method_call)
        end

        context '#move_to_tmp_dir' do
          let(:method) { :move_to_tmp_dir }
          it_behaves_like(:method_call)
        end

        context '#create_nonexistent_dirs' do
          let(:method) { :create_nonexistent_dirs }
          it_behaves_like(:method_call)
        end

        context '#copy_from_test_dir' do
          let(:method) { :copy_from_test_dir }
          it_behaves_like(:method_call)
        end
      end
    end

    describe '#clear' do
      let(:instance_methods) do
        %i[delete_test_files restore_tracking_files delete_nonexistent_dirs]
      end

      before do
        instance_methods.each do |method|
          allow_any_instance_of(subject.class).to receive(method).and_return(true)
        end
      end

      describe 'method call' do
        context '#delete_test_files' do
          let(:method) { :delete_test_files }
          it_behaves_like(:method_call)
        end

        context '#restore_tracking_files' do
          let(:method) { :restore_tracking_files }
          it_behaves_like(:method_call)
        end

        context '#delete_nonexistent_dirs' do
          let(:method) { :delete_nonexistent_dirs }
          it_behaves_like(:method_call)
        end
      end
    end
  end
end
