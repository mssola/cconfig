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

module CConfig
  # FormatError is the exception to be raised when a configuration file cannot
  # be parsed.
  class FormatError < StandardError
    DEFAULT_MSG = "Wrong format for the config-local file!".freeze

    def initialize
      super(DEFAULT_MSG)
    end
  end
end
