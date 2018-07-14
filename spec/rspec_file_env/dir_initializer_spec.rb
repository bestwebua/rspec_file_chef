module RspecFileEnv
  TestClass = Class.new do
    include DirInitializer
    extend Dry::Configurable
    setting :rspec_path
    setting :custom_tmp_dir
    setting :custom_test_dir
  end

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

    describe '#check_config' do
      describe 'method call' do
        before do
          allow(subject).to receive(:custom_paths).and_return([])
          subject.send(:check_config)
        end

        after { subject.send(:check_config) }
        specify { expect(subject).to receive(:custom_paths) }
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


  end
end
