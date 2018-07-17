module RspecFileChef
  RSpec.describe 'RspecFileChef version' do
    specify { expect(VERSION).not_to be(nil) }
  end
end
