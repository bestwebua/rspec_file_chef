# RSpec File Chef
<a href="https://codeclimate.com/github/bestwebua/rspec_file_chef/maintainability"><img src="https://api.codeclimate.com/v1/badges/4d21c733276304e2e8e1/maintainability" /></a> <a href="https://codeclimate.com/github/bestwebua/rspec_file_chef/test_coverage"><img src="https://api.codeclimate.com/v1/badges/4d21c733276304e2e8e1/test_coverage" /></a> [![Gem Version](https://badge.fury.io/rb/rspec_file_chef.svg)](https://badge.fury.io/rb/rspec_file_chef)

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

## Public class methods

### .new

```ruby
RspecFileChef::FileChef.new(file)
```

Create new instance of RspecFileChef::FileChef. Passed argument is your file-list for your tracking files. It should be real or virtual absolute paths represented as a string. **Please note, file-names of tracking files should be unique, otherwise you get RuntimeError**. For instance:

```ruby
file1, file2, file3 = '/path/somefile1', '/path/path/somefile2', '/path/path/path/somefile3'
```

Also you can pass more than one argument, for instance:
```ruby
file_chef_instance = RspecFileChef::FileChef.new(file1, file2 file3, file_n)
```


## Public instance methods

### #make

```ruby
file_chef_instance.make
```

This method prepares your rspec environment files under curry sauce. So what happens when this method run? Your personal FileChef:

1. Creates a path_table. It consists all necessary info about your tracked files.
2. Moves your not virtual tracked files to temp dir.
3. Creates non existent dirs if you have used virtual files.
4. Copies your test examples from test dir to current environment.

### #clear

```ruby
file_chef_instance.clear
```

This method is washing dishes in your project folder and restores previous state of tracked files. What happens here?
1. Erases test files.
2. Restores tracking files.
3. Deletes non existent dirs if they were created for virtual files.

### Instance getters
---
### #tracking_files

```ruby
file_chef_instance.tracking_files
```

Returns list of your tracked files in a default order:

```ruby
# => ['/path/somefile1', '/path/path/somefile2', '/path/path/path/somefile3']
```


### #rspec_path

```ruby
file_chef_instance.rspec_path
```

Returns your project spec absolute path:
```ruby
# => '/absolute_path_to_your_project/spec'
```


### #tmp_dir

```ruby
file_chef_instance.tmp_dir
```

Returns your project tmp_dir absolute path. When default paths config using:
```ruby
# => '/absolute_path_to_your_project/spec/support/helpers/file_chef/temp_data'
```

When custom paths config using:
```ruby
# => '/your_absolute_custom_path/your_custom_temp_data_dir'
```


### #test_dir

```ruby
file_chef_instance.test_dir
```

Returns your project test_dir absolute path. When default paths config using:
```ruby
# => '/absolute_path_to_your_project/spec/support/helpers/file_chef/test_data'
```

When custom paths config using:
```ruby
# => '/your_absolute_custom_path/your_custom_test_data_dir'
```

Put into this dir your files if you want gem to use it as test data examples during your rspec tests run.

> Please note, file-names of tracking files should be unique, and have the same names as files that ```.tracking_files``` method returns. For instance, to use this case you should put: ```somefile1```, ```somefile2```, ```somefile3``` into your test folder.

### #test_files

```ruby
file_chef_instance.test_files
```

Returns list of test files absolute paths that existing in your test_dir folder. The returned list is represented as an array, the elements of which are sorted in the order like ```.tracking_files```  **It makes sense to use this method after method ```.make``` was run. Otherwise you will get empty array**.

```ruby
# => ['/your_test_dir_absolute_path/somefile1',
# =>  '/your_test_dir_absolute_path/somefile2',
# =>  '/your_test_dir_absolute_path/somefile3']
```

### #path_table

```ruby
file_chef_instance.path_table
```

Returns associative array, where all tracking file-names are represented as keys. As values returns array with next data-pattern: ```[absolute_file_path, absolute_parent_dir_path, file_exist?, level_depth_of_existing_dir_path]```. **It makes sense to use this method after method ```.make``` was run. Otherwise you will get empty hash**.

```ruby
# => {'somefile1' => [absolute_file_path, absolute_parent_dir_path, file_exist?, level_depth_of_existing_dir_path]}
```

## Examples of using

###Real and virtual files, what does it mean?

Real file is an existing file which state you want to keep during running tests. Virtual file is a file the state of which you want to control, but this file not exist until you run tests.

**1. Using as cleaner**

For example, you know which file your app logged. Before your tests run your log-file not existen. You need to check is your app write the log during your tests. But you don't wont to see this log after your tests. This is case for using virtual files. Just pass the absolute path for this file/files as argument: ```RspecFileChef::FileChef.new(your_virtual_file)```.

**2. Using as file switcher**

Your project has use some local data files. You need that this file/files has contain a certain data before you run tests. Just pass the absolute path for this file/files as argument: ```RspecFileChef::FileChef.new(your_file)``` and put file/files with same name(s) into your test_dir. Your file can be either real or virtual. FileChef saves the file state if file is real, and uses example from test_dir during your test run. Otherwise FileChef just uses file from test_dir when your tests running.

###FileChef config examples

**1. Using default gem paths**

```ruby
# your_project/spec/some_test_class_spec.rb
require 'rspec_file_chef'

RSpec.describe SomeTestClass do
  before(:context) do
    RspecFileChef::FileChef.configure do |config|
      config.rspec_path = File.expand_path(__dir__)
    end

    file = '/path/somefile1'

    @env = RspecFileChef::FileChef.new(file)
    @env.make
  end

  after(:context) do
    @env.clear
  end
end
```

**2. Using your custom paths**

```ruby
# your_project/spec/some_test_class_spec.rb
require 'rspec_file_chef'

RSpec.describe SomeTestClass do
  before(:context) do
    RspecFileChef::FileChef.configure do |config|
      config.custom_tmp_dir = 'your_absolute_path_to_existing_tmp_dir'
      config.custom_test_dir = 'your_absolute_path_to_existing_test_dir'
    end

    file1, file2, file3 = '/path/somefile1', /path/path/somefile2', '/path/path/path/somefile3'

    @env = RspecFileChef::FileChef.new(file1, file2, file3)
    @env.make
  end

  after(:context) do
    @env.clear
  end
end
```

**3. Common configuration for all tests**

```ruby
# your_project/spec/spec_helper.rb
require 'rspec_file_chef'

RspecFileChef::FileChef.configure do |config|
  config.rspec_path = File.expand_path(__dir__)
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bestwebua/rspec_file_chef. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The RSpec File Environment control application is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
