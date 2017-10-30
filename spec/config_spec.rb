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

require "cconfig/cconfig"

# Returns a Config configured with the two given config files.
def get_config(default, local)
  base    = File.join(File.dirname(__FILE__), "fixtures")
  default = File.join(base, default)
  local   = File.join(base, local)
  ::CConfig::Config.new(default: default, local: local, prefix: "test")
end

describe CConfig::Config do
  after do
    ["TEST_LOCAL_CONFIG_PATH", "TEST_EMAIL_SMTP_ENABLED"].each { |key| ENV[key] = nil }
    ["TEST_LDAP_COUNT", "TEST_ANOTHER_ENABLED", "TEST_LDAP_STRING"].each do |key|
      ENV[key] = nil
    end
  end

  it "selects the proper local file depending of the environment variable" do
    # Instead of bad.yml (which will raise an error on `fetch`), we will pick up
    # the local.yml file.
    base  = File.join(File.dirname(__FILE__), "fixtures")
    local = File.join(base, "bad.yml")
    ENV["CCONFIG_LOCAL_CONFIG_PATH"] = File.join(base, "local.yml")

    # Passing nil to the prefix on purpose (see SUSE/Portus#1379)
    cfg = ::CConfig::Config.new(default: "config.yml", local: local, prefix: nil)
    expect { cfg.fetch }.not_to raise_error
  end

  describe "Merging configuration values" do
    it "returns an empty config if neither the global nor the local were found" do
      cfg = get_config("", "").fetch
      expect(cfg).to be_empty
    end

    it "only uses the global if the local config was not found" do
      cfg = get_config("config.yml", "").fetch
      expect(cfg["gravatar"]["enabled"]).to be_truthy
    end

    it "merges both config files and work as expected" do
      cfg = get_config("config.yml", "local.yml").fetch

      expect(cfg.enabled?("gravatar")).to be_truthy
      expect(cfg.enabled?("ldap")).to be_truthy
      expect(cfg["ldap"]["hostname"]).to eq "ldap.example.com"
      expect(cfg["ldap"]["port"]).to eq 389
      expect(cfg["ldap"]["base"]).to eq "ou=users,dc=example,dc=com"
      expect(cfg["unknown"]).to be nil
    end

    it "raises an error when the local file is badly formatted" do
      bad = get_config("config.yml", "bad.yml")
      msg =  "Wrong format for the config-local file!"
      expect { bad.fetch }.to raise_error(::CConfig::FormatError, msg)
    end

    it "returns the proper config while hiding passwords" do
      cfg     = get_config("config.yml", "local.yml")
      fetched = cfg.fetch
      evaled  = YAML.safe_load(cfg.to_s)

      expect(fetched).not_to eq(evaled)
      fetched["ldap"]["authentication"]["password"] = "****"
      expect(fetched).to eq(evaled)
    end
  end

  describe "#enabled?" do
    it "works for nested options" do
      cfg = get_config("config.yml", "").fetch
      expect(cfg.enabled?("email.smtp")).to be true
    end

    it "works with environment variables" do
      ENV["TEST_EMAIL_SMTP_ENABLED"] = "false"
      cfg = get_config("config.yml", "").fetch
      expect(cfg.enabled?("email.smtp")).to be false
    end

    it "offers the #disabled? method" do
      cfg = get_config("config.yml", "").fetch
      expect(cfg.disabled?("ldap")).to be_truthy
    end
  end

  describe "#default_of" do
    it "returns the default when a local file has been added" do
      cfg = get_config("config.yml", "local.yml").fetch

      expect(cfg["ldap"]["hostname"]).to eq("ldap.example.com")
      expect(cfg.default_of("ldap.hostname")).to eq("ldap_hostname")
    end

    it "returns the default even if an environment variable was set" do
      ENV["TEST_LDAP_AUTHENTICATION_BIND_DN"] = "2"
      cfg = get_config("config.yml", "local.yml").fetch

      expect(cfg["ldap"]["authentication"]["bind_dn"]).to eq(2)
      expect(cfg.default_of("ldap.authentication.bind_dn")).to eq("")
    end

    it "returns nil for an unknown key" do
      cfg = get_config("config.yml", "local.yml").fetch
      expect(cfg.default_of("something.that.does.not.exist")).to be_nil
    end
  end
end
