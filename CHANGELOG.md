# Changelog

## 1.2.1

- Added support for Ruby 2.5 and 2.6: nothing has really been done besides
  adding 2.5 and 2.6 into the CI system and such.
- Fixed the `#enabled?` method for nested `enabled` directives. See
  [commit](ec0d01c153d5157b08865821b9c679eeae450c35).

## 1.2.0

- Added the `#default_of` method for the returned hash (hence `APP_CONFIG` as
  well). This method returns the default value for a given key. It can be useful
  to check whether a configuration value has been set by either environment
  variables or the local configuration. See
  [commit](50d638c8d81bab6b17164a1a5661dc2ca730cf92).

## 1.1.1

- Fixed crash on nested values on the `#enabled?` method. See
  [#3](https://github.com/mssola/cconfig/issues/3).
- The `prefix` argument from the constructor now takes a default
  (`cconfig`). This will make things more predictable I hope.

## 1.1.0

- Added the `disabled?` method, which is a shorthand for `enabled?`.

## 1.0.0

- First release which includes the following features:
  - You can have a `config.yml` and a `config-local.yml` file. The first file is
    the reference configuration, while the other overwrites it with the given
    values.
  - You can override either the `config.yml` and the `config-local.yml` files
    with environment variables that start with a given prefix.
  - The location of the `config-local.yml` file can be configured through the
    `${prefix}_LOCAL_CONFIG_PATH` environment variable.
  - A Railtie has been written so it can be better used in Ruby on Rails
    applications.
