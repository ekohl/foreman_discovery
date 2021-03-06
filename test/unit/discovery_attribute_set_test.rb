require 'test_plugin_helper'

class DiscoveryAttributeSetTest < ActiveSupport::TestCase

  setup do
    @facts = parse_json_fixture('/facts.json')['facts']
    FactoryGirl.create(:setting,
                       :name => 'discovery_hostname',
                       :value => 'discovery_bootif',
                       :category => 'Setting::Discovered')
    FactoryGirl.create(:setting,
                       :name => 'discovery_prefix',
                       :value => 'mac',
                       :category => 'Setting::Discovered')
  end

  test "can search discovered hosts by cpu" do
    host = discover_host_from_facts(@facts)
    results = Host::Discovered.search_for("cpu_count = #{host.facts_hash['physicalprocessorcount'].to_i}")
    assert_equal 1, results.count
    results = Host::Discovered.search_for("cpu_count > #{host.facts_hash['physicalprocessorcount'].to_i}")
    assert_equal 0, results.count
  end

  test "can search discovered hosts by memory" do
    host = discover_host_from_facts(@facts)
    results = Host::Discovered.search_for("memory = #{host.facts_hash['memorysize_mb'].to_f.ceil}")
    assert_equal 1, results.count
    results = Host::Discovered.search_for("memory > #{host.facts_hash['memorysize_mb'].to_f.ceil}")
    assert_equal 0, results.count
  end

  test "can search discovered hosts by disk_count" do
    host = discover_host_from_facts(@facts)
    results = Host::Discovered.search_for("disk_count = 1")
    assert_equal 1, results.count
    results = Host::Discovered.search_for("disk_count = 3")
    assert_equal 0, results.count
  end

  test "can search discovered hosts by disks_size" do
    host = discover_host_from_facts(@facts)
    disks_size = (host.facts_hash['blockdevice_sda_size'].to_f / 1024 / 1024).ceil
    results = Host::Discovered.search_for("disks_size = #{disks_size}")
    assert_equal 1, results.count
    results = Host::Discovered.search_for("disks_size > #{disks_size}")
    assert_equal 0, results.count
  end

  def parse_json_fixture(relative_path)
    return JSON.parse(File.read(File.expand_path(File.dirname(__FILE__) + relative_path)))
  end
end
