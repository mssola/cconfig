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

module CConfig
  # HashUtils provides a handful of methods that help with the manipulation of
  # hashes in the gem.
  module HashUtils
    # Extensions contains the methods to be provided for each hash object
    # produced by this gem.
    module Extensions
      # Returns true if the given feature is enabled, false otherwise. This also
      # works in embedded configuration values. For example: enabled?("a.b")
      # will return true for:
      #   a:
      #     b:
      #       enabled: true
      def enabled?(feature)
        objs = feature.split(".")
        if objs.length == 2
          return false if !self[objs[0]][objs[1]] || self[objs[0]][objs[1]].empty?
          self[objs[0]][objs[1]]["enabled"].eql?(true)
        else
          return false if !self[feature] || self[feature].empty?
          self[feature]["enabled"].eql?(true)
        end
      end
    end

    protected

    # Applies a deep merge while respecting the values from environment
    # variables. A deep merge consists of a merge of all the nested elements of
    # the two given hashes `config` and `local`. The `config` hash is supposed
    # to contain all the accepted keys, and the `local` hash is a subset of it.
    #
    # Moreover, let's say that we have the following hash: { "ldap" => {
    # "enabled" => true } }. An environment variable that can modify the value
    # of the previous hash has to be named `#{prefix}_LDAP_ENABLED`. The `prefix`
    # argument specifies how all the environment variables have to start.
    #
    # Returns the merged hash, where the precedence of the merge is as follows:
    #   1. The value of the related environment variable if set.
    #   2. The value from the `local` hash.
    #   3. The value from the `config` hash.
    def strict_merge_with_env(default:, local:, prefix:)
      hsh = {}

      default.each do |k, v|
        # The corresponding environment variable. If it's not the final value,
        # then this just contains the partial prefix of the env. variable.
        env = "#{prefix}_#{k}"

        # If the current value is a hash, then go deeper to perform a deep
        # merge, otherwise we merge the final value by respecting the order as
        # specified in the documentation.
        if v.is_a?(Hash)
          l = local[k] || {}
          hsh[k] = strict_merge_with_env(default: default[k], local: l, prefix: env)
        else
          hsh[k] = first_non_nil(get_env(env), local[k], v)
        end
      end
      hsh
    end

    # Hide any sensitive value, replacing it with "*" characters.
    def hide_password(hsh)
      hsh.each do |k, v|
        if v.is_a?(Hash)
          hsh[k] = hide_password(v)
        elsif k == "password"
          hsh[k] = "****"
        end
      end
      hsh
    end

    private

    # Get the typed value of the specified environment variable. If it doesn't
    # exist, it will return nil. Otherwise, it will try to cast the fetched
    # value into the proper type and return it.
    def get_env(key)
      env = ENV[key.upcase]
      return nil if env.nil?

      # Try to convert it into a boolean value.
      return true if env.casecmp("true").zero?
      return false if env.casecmp("false").zero?

      # Try to convert it into an integer. Otherwise just keep the string.
      begin
        Integer(env)
      rescue ArgumentError
        env
      end
    end

    # Returns the first value that is not nil from the given argument list.
    def first_non_nil(*values)
      values.each { |v| return v unless v.nil? }
    end
  end
end
