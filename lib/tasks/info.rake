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

namespace :cconfig do
  desc "Prints the evaluated configuration"
  task :info, [:prefix] => :environment do |_, args|
    prefix  = args[:prefix]
    default = File.join(Rails.root, "config", "config.yml")
    local   = File.join(Rails.root, "config", "config-local.yml")

    # Note that local will change if "#{prefix.upcase}_LOCAL_CONFIG_PATH" was
    # specified.
    cfg = ::CConfig::Config.new(default, local, prefix)
    puts "Evaluated configuration:\n#{cfg}"
  end
end
