# CConfig [![Build Status](https://travis-ci.org/mssola/cconfig.svg?branch=master)](https://travis-ci.org/mssola/cconfig) [![Gem Version](https://badge.fury.io/rb/cconfig.svg)](https://badge.fury.io/rb/cconfig)

CConfig (Container Config) is a container-aware configuration management
gem. This is useful for applications that want to keep a reference configuration
and add modifications to it in two different ways:

- An alternative configuration file that lists all the modifications.
- A list of environment variables that follow a given naming policy.

## Basic usage

Let's assume that our application has a `config.yml` file that contains all the
possible configurable values with their defaults:

```yaml
option:
  enabled: true

another:
  value: 5
```

Then, you will have the following (irb prompt):

```
>> require "cconfig/cconfig"
>> cfg = ::CConfig::Config.new(default: "config.yml", local: "", prefix: "")
>> obj = cfg.fetch
>> puts obj
=> {"option"=>{"enabled"=>true}, "another"=>{"value"=>5}}
```

Moreover, this gem also adds an `enabled?` method to this hash returned by
`#fetch`. With this method, configurable values with an `enabled` boolean value
will have this shorthand available. For example:

```
>> obj.enabled?("option")
=> true
>> obj.enabled?("another")
=> false
```

This also works for embedded configurable options. From the above example, let's
assume that we update the `config.yml` file with these contents:

```yaml
option:
  enabled: true

  embedded:
    enabled: false

another:
  value: 5
```

Let's also add an alternative configuration file with these contents:

```yaml
option:
  embedded:
    enabled: true
```

Then we have the following:

```
>> cfg = ::CConfig::Config.new(default: "config.yml", local: "config-local.yml", prefix: "")
>> obj = cfg.fetch
=> {"option"=>{"enabled"=>true, "embedded"=>{"enabled"=>true}}, "another"=>{"value"=>5}}
>> obj.enabled?("option.embedded")
=> true
```

As you can see, the contents from the `config-local.yml` file that are available
in the `config.yml` have been overwritten.

That being said, mounting a volume for changing some default values inside of a
Docker container is a bit of an overkill. So, instead you can use **environment
variables**. In the above example we can add an environment variable (shell prompt):

```
$ export APPLICATION_ANOTHER_VALUE=2
```

Then (irb prompt):

```
>> cfg = ::CConfig::Config.new(default: "config.yml", local: "config-local.yml", prefix: "application")
>> cfg.fetch
=> {"option"=>{"enabled"=>true, "embedded"=>{"enabled"=>true}}, "another"=>{"value"=>2}}
```

Moreover, the environment variable value takes precedence over the
`config-local.yml` file.

## Ruby on Rails integration

This gem also provides a Railtie, so it can be better used inside of a Ruby on
Rails application.

First of all, this Railtie will initialize a global constant named `APP_CONFIG`
automatically with the merged contents of the configuration files and
environment variables. Some notes:

- The *prefix* is taken from the Rails' application name. If you don't want
  this, set the `CCONFIG_PREFIX` environment variable.
- The file with the default values has to be located in `config/config.yml` from
  your Ruby on Rails root directory. Moreover, the other file is located in
  `config/config-local.yml`, but this can be changed by setting the
  `#{prefix}_LOCAL_CONFIG_PATH` environment variable.

Last but not least, this Railtie also offers a rake task called
`cconfig:info`. This rake task prints to standard output the evaluated
configuration.

This gem supports Ruby on Rails `5.x` and `6.x`.

## Contributing

Read the [CONTRIBUTING.md](./CONTRIBUTING.md) file.

## [Changelog](https://pbs.twimg.com/media/DJDYCcLXcAA_eIo?format=jpg&name=small)

Read the [CHANGELOG.md](./CHANGELOG.md) file.

## License

This project is based on work I did for the
[Portus](https://github.com/SUSE/Portus) project. I've extracted my code into a
gem so it can be also used for other projects that might be interested in this.

```
Copyright (C) 2017-2021 Miquel Sabaté Solà <msabate@suse.com>

CConfig is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

CConfig is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with CConfig.  If not, see <http://www.gnu.org/licenses/>.
```
