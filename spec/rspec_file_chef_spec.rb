module RspecFileChef
  RSpec.describe RspecFileChef do
    specify { expect(subject).to be_const_defined(:VERSION) }
  end
end
