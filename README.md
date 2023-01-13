<!--
LoCAl is a simple Certificate Authority bot.
Copyright (C) 2023  Alex Speranza

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
-->

# Local

LoCAl is a daemon which acts as a local Certificate Authority. It can have a self-signed certificate and can issue certificates.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add local

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install local

## Usage

Run `exe/local` to start the program.

### Configuration
#### ENV
The available ENV variables are:
| Name | Type | Default value | Description |
|---|---|---|---|
| CONFIG_FILE | string (path) |  | The path of the config file. |
| LOG_FILE_PATH | string (path) | `./local.log` | The path of the log file. |

#### Configuration file
An example configuration file can be found [in the repository](example-config.yaml).

## Development
This repository contains a `.ruby_version` file for [rbenv](https://github.com/rbenv/rbenv). To avoid errors due to a different Ruby version, I encourage you to use `rbenv` and, if necessary, install the version defined in `.ruby_version`.

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/asperan/local.

## References
These are the main sites where I got the knowledge:
- https://myhomelab.gr/linux/2019/12/13/local-ca-setup.html
- https://www.golinuxcloud.com/renew-self-signed-certificate-openssl/
- https://stackoverflow.com/questions/60644617/curl-says-requested-domain-name-does-not-match-the-servers-certificate-but-i
- https://stackoverflow.com/questions/6194236/openssl-certificate-version-3-with-subject-alternative-name
- https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2

## License

LoCAl is distributed under the terms of the [GNU Affero General Public License v3.0](LICENSE).
