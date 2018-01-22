# frozen_string_literal: true

# Copyright (C) 2017-2018 Miquel Sabaté Solà <msabate@suse.com>
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

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require "simplecov"

SimpleCov.minimum_coverage 100
SimpleCov.start do
  add_group "lib", "lib"
end

RSpec.configure do |config|
  config.order = :random
end
