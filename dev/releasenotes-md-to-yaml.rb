#!/usr/bin/env ruby
require 'yaml'

CONFIG_DIR = File.join(File.dirname(__FILE__), '../config')

releases = Dir.glob("#{CONFIG_DIR}/releases/**/*.md").map do |rel_file|
  raw = File.read(rel_file)
  data = YAML.safe_load(raw)
  description = raw.force_encoding('UTF-8').split('---').slice(2).strip
  data.merge('description' => description)
end
  .sort_by do |r| # semver sort
    [ r['version_major'].to_i,
      r['version_minor'].to_i,
      r['version_patch'].to_i,
      (r['version_pre']||'').to_s.split('.')
    ].flatten.map do |i| i.to_s.rjust(8, '0') end
  end
  .reverse

fail 'no data!' unless releases.length > 0

File.write("#{CONFIG_DIR}/releases.yml", {'releases' => releases}.to_yaml)
