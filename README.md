# RSpec File Chef
The main idea of this gem is saving previous state of tracking files after running RSpec. It should be helpful when your project is using own local files for record some data or a log. And you don't want that RSpec will change it. Or you don't want to get a lot of temporary test files in your project root folder after your tests complete.

## Features

- Tracking of necessary files
  - Supporting of virtual files
  - Saving/restoring current state of tracking files
- Supporting of tracking files test examples
- Ability to use custom location for test examples and temp directory

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec_file_chef'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec_file_chef

## Usage

```ruby
# your_project/spec/some_test_class_spec.rb

require 'rspec_file_chef'
RSpec.describe SomeTestClass do
  before(:context) do

    # If you don't want use custom paths config your rspec_path only
    RspecFileChef::FileChef.configure do |config|
      config.rspec_path = File.expand_path(__dir__)
    end

    # Config as below if you want use your custom paths only
    RspecFileChef::FileChef.configure do |config|
      config.custom_tmp_dir = File.expand_path(__dir__)
      config.custom_test_dir = File.expand_path(__dir__)
    end

    @env = RspecFileChef::FileChef.new(file1, file2)
    @env.make
  end

  after(:context) do
    @env.clear
  end
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bestwebua/rspec_file_chef. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The RSpec File Environment control application is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
