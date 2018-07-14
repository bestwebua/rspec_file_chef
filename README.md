# RSpec File Chef
The main idea of this gem is saving previous state of tracking files after running RSpec. It should be helpful when your project is using own local files for record some data or a log. And you don't want that RSpec will change it. Or you don't want to get a lot of temporary test files in your project root folder after your tests complete.

## Features

1. Tracking of necessary files
2. Saving current tracking files if they exists
3. Copying the same test files if they exists
4. Restoring the previous state of your project folder

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bestwebua/rspec_file_chef. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The RSpec File Environment control application is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
