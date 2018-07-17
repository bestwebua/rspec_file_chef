# RSpec File Chef
The main idea of this gem is saving previous state of tracking files after running RSpec. It should be helpful when your project is using it's own local files to record some data or a log. And you don't want RSpec to change it. Or you don't want to get a lot of temporary test files in your project root folder after your tests were complete.

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

## Class configuration
Before creating class instance you should configurate your FileChef class, otherwise you get RuntimeError.

If you don't want to use custom paths configurate your rspec_path only:
```ruby
RspecFileChef::FileChef.configure do |config|
  config.rspec_path = 'your_absolute_path_to_project_rspec_dir'
end
```

Configurate as below if you want to use your custom paths only:
```ruby
RspecFileChef::FileChef.configure do |config|
  config.custom_tmp_dir = 'your_absolute_path_to_existing_tmp_dir'
  config.custom_test_dir = 'your_absolute_path_to_existing_test_dir'
end
```

## Public methods

### .new
Create new instance of RspecFileChef::FileChef.

```ruby
RspecFileChef::FileChef.new(file)
```

Passed argument is your file-list for your tracking files. It should be real or virtual absolute paths represented as a string. Please note, file-names of tracking files should be unique, for instance:

```ruby
file1, file2, file3 = '/path/somefile1', '/path/path/somefile2', '/path/path/path/somefile3'
```

Also you can pass more than one argument, for instance:
```ruby
file_chef_instance = RspecFileChef::FileChef.new(file1, file2 file3, file_n)
```
---

### .make
This method prepares your rspec environment files under curry sauce. So what happens when this method run?
Your personal FileChef:
1. Creates a path_table. It consists all necessary info about your tracked files.
2. Moves your not virtual tracked files to temp dir.
3. Creates non existent dirs if you have used virtual files.
4. Copies your test examples from test dir to current environment.

```ruby
file_chef_instance.make
```
---

### .clear
This method is washing dishes in your project folder and restores previous state of tracked files. What happens here?
1. Erases test files.
2. Restores tracking files.
3. Deletes non existent dirs if they were created for virtual files.

```ruby
file_chef_instance.clear
```
---

### Class getters

#### .tracking_files
Returns list of your tracked files in a default order:
```ruby
file_chef_instance.tracking_files
# => ['/path/somefile1', '/path/path/somefile2', '/path/path/path/somefile3']
```

#### .rspec_path
Returns your project spec absolute path:
```ruby
file_chef_instance.rspec_path
# => '/your_project/spec'
```

#### .tmp_dir
Returns your project tmp_dir absolute path:
```ruby
file_chef_instance.tmp_dir
# default paths config using
# => '/your_project/spec/support/helpers/file_chef/temp_data'

# custom paths config using
# => '/your_custom_path/your_custom_temp_data_dir'
```

#### .test_dir
Returns your project test_dir absolute path.
```ruby
file_chef_instance.test_dir
# default paths config using
# => '/your_project/spec/support/helpers/file_chef/test_data'

# custom paths config using
# => '/your_custom_path/your_custom_test_data_dir'
```

Put into this dir your files if you want gem to use it as test data examples during your rspec tests run.

> Please note, file-names of tracking files should be unique, and have the same names as files that ```.tracking_files``` method returns. For instance, to use this case you should put: ```somefile1```, ```somefile2```, ```somefile3``` into your test folder.

#### It makes sense to use getters below after method ```.make``` was run
#### .test_files
Returns list of test files absolute paths that existing in your test_dir folder:
```ruby
file_chef_instance.test_files
# => ['/your_test_dir/somefile1', '/your_test_dir/somefile2', '/your_test_dir/somefile2']
```


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
      config.custom_tmp_dir = 'your_absolute_path_to_existing_tmp_dir'
      config.custom_test_dir = 'your_absolute_path_to_existing_test_dir'
    end
    
    # Add files for tracking. It should be real or virtual absolute paths
    # represented as a string. You can path more than one argument,
    # for instance: RspecFileChef::FileChef.new(file1, file2)

    # Please note, file-names of tracking files should be unique, for instance:
    # file1 = '/path/somefile1'
    # file2 = '/path/path/somefile2'
    # file2 = '/path/path/path/somefile3'

    @env = RspecFileChef::FileChef.new(file)
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
