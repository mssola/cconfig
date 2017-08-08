# Changelog

## 1.0.0

- First release which includes the following features:
  - You can have a `config.yml` and a `config-local.yml` file. The first file
    is the reference configuration, while the other overwrites it with the given
    values.
  - You can override either the `config.yml` and the `config-local.yml` files
    with environment variables that start with a given prefix.
  - The location of the `config-local.yml` file can be configured through the
    `${prefix}_LOCAL_CONFIG_PATH` environment variable.
  - A Railtie has been written so it can be better used in Ruby on Rails
    applications.
