module RspecFileEnv
  TestClass = Class.new do
    include DirInitializer
  end

  RSpec.describe TestClass do
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

    describe '' do

    end


  end
end
