module RspecFileChef
  RSpec.describe Error do
    specify { expect(subject).to have_constant(Error::RSPEC_PATH) }
    specify { expect(subject).to have_constant(Error::CONFIG) }
    specify { expect(subject).to have_constant(Error::CUSTOM_PATHS) }
  end
end
