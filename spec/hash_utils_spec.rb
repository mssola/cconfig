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

class ConfigMock
  include ::CConfig::HashUtils

  def strict_merge_with_env_test(default:, local:, prefix:)
    strict_merge_with_env(default: default, local: local, prefix: prefix)
  end
end

describe ::CConfig::HashUtils do
  after do
    %w[TEST_LDAP_COUNT TEST_ANOTHER_ENABLED TEST_LDAP_STRING].each do |key|
      ENV[key] = nil
    end
  end

  let(:default) do
    {
      "gravatar" => { "enabled" => true },
      "another"  => { "enabled" => true },
      "ldap"     => {
        "enabled" => false,
        "count"   => 0,
        "string"  => ""
      }
    }.freeze
  end

  let(:local) do
    {
      "ldap" => {
        "enabled" => true,
        "count"   => 1
      }
    }.freeze
  end

  it "merges hashes in a strict manner while evaluating env variables first" do
    ENV["TEST_LDAP_COUNT"] = "2"
    ENV["TEST_ANOTHER_ENABLED"] = "false"
    ENV["TEST_LDAP_STRING"] = "string"

    cfg = ConfigMock.new.strict_merge_with_env_test(default: default, local: local, prefix: "test")
    expect(cfg["gravatar"]["enabled"]).to be true # default
    expect(cfg["another"]["enabled"]).to be false # env
    expect(cfg["ldap"]["enabled"]).to be true     # local
    expect(cfg["ldap"]["count"]).to eq 2          # env
    expect(cfg["ldap"]["string"]).to eq "string"  # env
  end

  # See issue #3
  it "does not crash on nested default that doesn't exist" do
    cfg = ConfigMock.new.strict_merge_with_env_test(default: default, local: local, prefix: "test")

    cfg.extend(::CConfig::HashUtils::Extensions)
    expect(cfg).to be_enabled("gravatar")
    expect(cfg).not_to be_enabled("oauth.google_oauth2")
    expect(cfg).not_to be_enabled("something.that.does.not.exist")
  end
end
