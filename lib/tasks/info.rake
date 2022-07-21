# frozen_string_literal: true

# Copyright (C) 2017-2022 Miquel Sabaté Solà <msabate@suse.com>
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

require 'yaml'

# This is indeed identical to the `hide_password` method from the HashUtils
# module. That being said, it's easier to just repeat this simple piece of code
# than restructure things around.
def to_secure_hash(hsh)
  hsh.each do |k, v|
    if v.is_a?(Hash)
      hsh[k] = to_secure_hash(v)
    elsif k == 'password'
      hsh[k] = '****'
    end
  end
end

namespace :cconfig do
  desc 'Prints the evaluated configuration'
  task :info, [:prefix] => :environment do |_, args|
    # If this is a Rails application, chances are that when calling this Rake
    # task the `::APP_CONFIG` variable has already been set by the Rails
    # initializer.
    if defined?(::APP_CONFIG)
      hsh = to_secure_hash(::APP_CONFIG)
      puts "Evaluated configuration:\n#{hsh.to_yaml}"
      next
    end

    # There might be a weird case in which Rails is being used but the
    # `::APP_CONFIG` variable has not been set. In these cases, try to fetch the
    # application name from within Rails if a prefix was not given.
    prefix = if args[:prefix].nil? && defined?(Rails)
               ::CConfig::Railtie.fetch_prefix(Rails.application)
             else
               args[:prefix]
             end

    default = File.join(Rails.root, 'config', 'config.yml')
    local   = File.join(Rails.root, 'config', 'config-local.yml')

    # Note that local will change if "#{prefix.upcase}_LOCAL_CONFIG_PATH" was
    # specified.
    cfg = ::CConfig::Config.new(default: default, local: local, prefix: prefix)
    puts "Evaluated configuration:\n#{cfg}"
  end
end
