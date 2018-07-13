module RspecFileEnv
  RSpec.describe 'RspecFileEnv version' do
    specify { expect(VERSION).not_to be(nil) }
  end
end
