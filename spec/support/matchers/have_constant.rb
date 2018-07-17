RSpec::Matchers.define(:have_constant) do |const|
  match do |owner|
    defined?(const)
  end
end
