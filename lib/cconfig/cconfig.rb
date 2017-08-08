# coding: utf-8
# Copyright (C) 2017 Miquel Sabaté Solà <msabate@suse.com>
#
# This file is part of CConfig.
#
# CConfig is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# CConfig is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with CConfig.  If not, see <http://www.gnu.org/licenses/>.

require "cconfig/hash_utils"
require "cconfig/errors"
require "yaml"

module CConfig
  # Config is the main class of this library. It allows you to fetch the current
  # configuration (after merging the values from all sources) as a hash. This
  # has will have the special method `::CConfig::HashUtils::Extensions#enabled?`.
  class Config
    include ::CConfig::HashUtils

    # Instantiate an object with `default` as the path to the default
    # configuration, `local` as the alternate file, and `prefix` as the prefix
    # for environment variables.
    #
    # Note: the `local` value will be discarded in favor of the
    # `#{prefix}_LOCAL_CONFIG_PATH` environment variable if it was set.
    def initialize(default:, local:, prefix:)
      @default = default
      @local   = ENV["#{prefix.upcase}_LOCAL_CONFIG_PATH"] || local
      @prefix  = prefix
    end

    # Returns a hash with the app configuration contained in it.
    def fetch
      cfg   = {}
      cfg   = YAML.load_file(@default) if File.file?(@default)
      local = fetch_local

      hsh = strict_merge_with_env(default: cfg, local: local, prefix: @prefix)
      hsh.extend(::CConfig::HashUtils::Extensions)
    end

    # Returns a string representation of the evaluated configuration.
    def to_s
      hide_password(fetch.dup).to_yaml
    end

    protected

    # Returns a hash with the alternate values that have to override the default
    # ones.
    def fetch_local
      if File.file?(@local)
        # Check for bad user input in the local config.yml file.
        local = YAML.load_file(@local)
        raise FormatError unless local.is_a?(::Hash)
        local
      else
        {}
      end
    end
  end
end