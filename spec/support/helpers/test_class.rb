module RspecFileChef
  TestClass = Class.new do
    include DirInitializer
    include StateKeeper
    extend Dry::Configurable
    setting :rspec_path
    setting :custom_tmp_dir
    setting :custom_test_dir
  end
end
