module RspecFileChef
  RSpec.describe TestClass do
    let(:this_path)       { File.expand_path(__dir__) }
    let(:rspec_path)      { this_path }
    let(:custom_tmp_dir)  { "#{this_path}/tmp_dir" }
    let(:custom_test_dir) { "#{this_path}/test_dir" }

    let(:apply_config) do
      subject.class.configure do |config|
        config.rspec_path = rspec_path
        config.custom_tmp_dir = custom_tmp_dir
        config.custom_test_dir = custom_test_dir
      end
    end

    let(:clear_config) do
      subject.class.configure do |config|
        config.rspec_path = nil
        config.custom_tmp_dir = nil
        config.custom_test_dir = nil
      end
    end

    after { clear_config }

    describe 'Constants' do
      specify { expect(subject).to have_constant(DirInitializer::HELPER_PATH) }
    end

    describe '#rspec_pattern' do
      let(:regex_pattern) { subject.send(:rspec_pattern) }
      let(:right_path_1)   { %w[/path/spec /path/spec/ /path/spec/spec /path/spec/spec/] }
      let(:one_level_path) { lambda { |path| path[regex_pattern] == '/path' } }
      let(:right_path_2)   { %w[/path/rspec/spec /path/rspec/spec/ /path/rspec/spec/path /path/rspec/spec/path/] }
      let(:two_level_path) { lambda { |path| path[regex_pattern] == '/path/rspec' } }
      let(:wrong_path)     { %w[/path/speca /path/speca/] }
      let(:nil_path)       { lambda { |path| path[regex_pattern].nil? } }

      specify { expect(regex_pattern).to be_an_instance_of(Regexp) }
      specify { expect(right_path_1.all?(&one_level_path)).to be(true) }
      specify { expect(right_path_2.all?(&two_level_path)).to be(true) }
      specify { expect(wrong_path.all?(&nil_path)).to be(true) }
    end

    describe 'class config getters' do
      before { apply_config }

      context '#default_rspec_path' do
        it "returns #{TestClass}.config.rspec_path" do
          expect(subject.class.config.rspec_path).to eq(rspec_path)
        end
      end

      context '#custom_tmp_dir' do
        it "returns #{TestClass}.config.custom_tmp_dir" do
          expect(subject.class.config.custom_tmp_dir).to eq(custom_tmp_dir)
        end
      end

      context '#custom_test_dir' do
        it "returns #{TestClass}.config.custom_test_dir" do
          expect(subject.class.config.custom_test_dir).to eq(custom_test_dir)
        end
      end
    end

    describe '#rspec_path' do
      specify { expect(subject.rspec_path).to be_nil }
    end

    describe '#set_rspec_path' do
      describe 'scenario' do
        before { apply_config }

        describe 'not raise error' do
          before { subject.send(:set_rspec_path) }

          context 'rspec path not set' do
            before do
              allow(subject).to receive(:default_rspec_path)
              subject.send(:set_rspec_path)
            end

            after { subject.send(:set_rspec_path) }
            
            let(:rspec_path) { nil }

            specify { expect(subject).to receive(:default_rspec_path) }
            specify { expect(subject.rspec_path).to be_nil }
          end

          context 'right rspec path' do
            before do
              allow(subject).to receive(:rspec_pattern)
              subject.send(:set_rspec_path)
            end

            after { subject.send(:set_rspec_path) }

            specify { expect(subject).to receive(:rspec_pattern) }
            specify { expect(subject.rspec_path).to_not be_nil }
          end
        end

        describe 'raise error' do
          context 'wrong rspec path' do
            let(:rspec_path) { '/some_wrong_path/without/spec_folder' }
            specify do
              expect {subject.send(:set_rspec_path)}.to raise_error(RuntimeError, Error::RSPEC_PATH)
            end
          end
        end
      end
    end

    describe '#custom_paths' do
      specify { expect(subject.send(:custom_paths)).to be_an_instance_of(Array) }

      context 'method call' do
        before do
          allow(subject).to receive(:custom_tmp_dir)
          allow(subject).to receive(:custom_tmp_dir)
          subject.send(:custom_paths)
        end

        after { subject.send(:custom_paths) }

        specify { expect(subject).to receive(:custom_tmp_dir) }
        specify { expect(subject).to receive(:custom_test_dir) }
      end
    end

    describe '#any_custom_path' do
      describe 'scenario' do
        let(:custom_paths_stub) do
          allow(subject).to receive(:custom_paths).and_return([1, 3])
        end

        context 'no block passed' do
          before { custom_paths_stub }
          specify { expect(subject.send(:any_custom_path)).to be(true) }
        end

        context 'block passed' do
          before { custom_paths_stub }
          specify { expect(subject.send(:any_custom_path, &:nil?)).to be(false) }
          specify { expect(subject.send(:any_custom_path, &:odd?)).to be(true) }
        end
      end
    end

    describe '#not_exist?' do
      specify { expect(subject.send(:not_exist?)).to be_an_instance_of(Proc) }
    end

    describe '#check_config' do
      describe 'method call' do
        before do
          allow(subject).to receive(:any_custom_path)
          subject.send(:check_config)
        end

        after { subject.send(:check_config) }
        specify { expect(subject).to receive(:any_custom_path) }
      end

      describe 'scenario' do
        context 'not raise error' do
          before { apply_config }
          specify do
            expect(subject.send(:check_config)).to be(true)
          end
        end

        context 'raise error' do
          before do
            allow(subject).to receive(:custom_paths).and_return([nil])
          end

          specify do
            expect {subject.send(:check_config)}.to raise_error(RuntimeError, Error::CONFIG)
          end
        end
      end
    end

    describe '#custom_paths_needed?' do
      describe 'scenario' do
        context 'rspec_path was set' do
          let(:rspec_path_true) { allow(subject).to receive(:rspec_path).and_return(true) }

          context 'metod call' do
            before { rspec_path_true; subject.send(:custom_paths_needed?) }
            after { subject.send(:custom_paths_needed?) }
            specify { expect(subject).to receive(:rspec_path) }
          end

          context 'returns boolean' do
            before { rspec_path_true }
            specify { expect(subject.send(:custom_paths_needed?)).to be(false) }
          end
        end

        context 'other paths was set' do
          before do
            allow(subject).to receive(:rspec_path).and_return(false)
            allow(subject).to receive(:check_config)
            subject.send(:custom_paths_needed?)
          end

          after { subject.send(:custom_paths_needed?) }

          context 'metod call' do
            specify { expect(subject).to receive(:check_config) }
          end
        end
      end
    end

    describe '#check_custom_paths' do
      describe 'scenario' do
        context 'non existent paths' do
          context 'method call' do
            before do
              allow(subject).to receive(:any_custom_path)
              subject.send(:check_custom_paths)
            end

            after { subject.send(:check_custom_paths) }
            specify { expect(subject).to receive(:any_custom_path) }
          end

          context 'raise error' do
            before do
              allow(subject).to receive(:any_custom_path).and_return(true)
            end

            specify do
              expect {subject.send(:check_custom_paths)}.to raise_error(RuntimeError, Error::CUSTOM_PATHS)
            end
          end
        end

        context 'existent paths' do
          before do
            allow(subject).to receive(:any_custom_path).and_return(false)
            allow(subject).to receive(:not_exist?)
            subject.send(:check_custom_paths)
          end

          after { subject.send(:check_custom_paths) }
          specify { expect(subject).to receive(:any_custom_path) }
          specify { expect(subject).to receive(:not_exist?) }
        end
      end
    end

    describe '#create_helper_dir' do
      describe 'scenario' do
        let(:create_helper_dir) { subject.send(:create_helper_dir) }
        let(:new_dir_location) do
          "#{subject.rspec_path}/#{DirInitializer::HELPER_PATH}"
        end

        before do
          allow(subject).to receive(:default_rspec_path).and_return(this_path)
          subject.send(:set_rspec_path)
        end

        after { FileUtils.remove_dir(new_dir_location) }

        context 'create folder' do
          before { create_helper_dir }
          specify { expect(Dir.exist?(new_dir_location)).to be(true) }
        end

        context 'returns new folders paths' do
          specify { expect(create_helper_dir).to be_an_instance_of(Array) }
          specify { expect(create_helper_dir).to_not be_empty }
          specify { expect(create_helper_dir.first).to eq("#{new_dir_location}/temp_data") }
          specify { expect(create_helper_dir.last).to eq("#{new_dir_location}/test_data") }
        end
      end
    end

    describe '#set_dir_paths' do
      describe 'set instance var' do
        let(:custom_paths_list) { %w[temp_data test_data] }
        let(:tmp_dir) { expect(subject.tmp_dir).to eq(custom_paths_list.first) }
        let(:test_dir) { expect(subject.test_dir).to eq(custom_paths_list.last) }

        shared_examples(:set_dir_paths_examples) do
          specify { method }
        end

        describe 'scenario' do
          context 'custom paths needed' do
            before do
              allow(subject).to receive(:custom_paths_needed?).and_return(true)
              allow(subject).to receive(:any_custom_path).and_return(false)
              allow(subject).to receive(:check_custom_paths)
              allow(subject).to receive(:custom_paths).and_return(custom_paths_list)
              subject.send(:set_dir_paths)
            end

            context '@temp_dir' do
              let(:method) { tmp_dir }
              it_behaves_like(:set_dir_paths_examples)
            end

            context '@test_dir' do
              let(:method) { test_dir }
              it_behaves_like(:set_dir_paths_examples)
            end
          end

          context 'custom paths not needed' do
            before do
              allow(subject).to receive(:custom_paths_needed?).and_return(false)
              allow(subject).to receive(:create_helper_dir).and_return(custom_paths_list)
              subject.send(:set_dir_paths)
            end

            context '@temp_dir' do
              let(:method) { tmp_dir }
              it_behaves_like(:set_dir_paths_examples)
            end

            context '@test_dir' do
              let(:method) { test_dir }
              it_behaves_like(:set_dir_paths_examples)
            end
          end
        end
      end
    end
  end
end
