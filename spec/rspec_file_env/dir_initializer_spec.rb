module RspecFileEnv
  TestClass = Class.new do
    include DirInitializer
    extend Dry::Configurable

    setting :rspec_path
    setting :custom_tmp_dir
    setting :custom_test_dir
  end

  RSpec.describe TestClass do
    let(:rspec_path) { File.expand_path(__dir__) }
    let(:custom_tmp_dir) { "#{rspec_path}/tmp_dir" }
    let(:custom_test_dir) { "#{rspec_path}/test_dir" }
    let(:apply_config) do
      subject.class.configure do |config|
        config.rspec_path = rspec_path
        config.custom_tmp_dir = custom_tmp_dir
        config.custom_test_dir = custom_test_dir
      end
    end

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


  end
end
