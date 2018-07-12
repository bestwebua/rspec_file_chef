require 'spec_helper'

module RspecFileEnv
  RSpec.describe RspecFileEnv do
    specify { expect(subject).to be_const_defined(:VERSION) }
  end
end
