# frozen_string_literal: true

# Copyright (C) 2017-2023 Miquel Sabaté Solà <msabate@suse.com>
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

require 'rails'

module CConfig
  # This class will set up this gem for Ruby on Rails:
  #   - On initialization this Railtie will set the `APP_CONFIG` global
  #     constant with the resulting merged values of the configuration.
  #   - The `cconfig:info` rake task will be loaded.
  class Railtie < Rails::Railtie
    railtie_name :cconfig

    initializer 'cconfig' do |app|
      prefix     = ::CConfig::Railtie.fetch_prefix(app)
      default    = Rails.root.join('config', 'config.yml')
      local      = Rails.root.join('config', 'config-local.yml')
      cfg        = ::CConfig::Config.new(default: default, local: local, prefix: prefix)

      # NOTE: this is a global constant from now on. The Rails application
      # expects this exact constant to be set by this Railtie.
      ::APP_CONFIG = cfg.fetch
    end

    rake_tasks do
      Dir[File.join(File.dirname(__FILE__), '../tasks/*.rake')].each do |task|
        load task
      end
    end

    # fetch_prefix returns a string containing the prefix to be used by our
    # CConfig::Config instance.
    #
    # app contains the Rails application as given by the railtie API.
    def self.fetch_prefix(app)
      if ENV['CCONFIG_PREFIX'].present?
        ENV['CCONFIG_PREFIX']
      elsif Rails::VERSION::MAJOR >= 6
        app.class.module_parent_name
      else
        app.class.parent_name.inspect
      end
    end
  end
end
