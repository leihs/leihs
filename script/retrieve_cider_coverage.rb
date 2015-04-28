require 'rubygems'

require 'cider_client'
require 'simplecov'
require 'optparse'
require 'pry'

options = {}
optparse = OptionParser.new do |opts|
  opts.banner = 'Usage: retrieve_cider_coverage.rb -e EXECUTION_ID'
  options[:execution_id] = nil

  opts.on('-e', '--execution EXECUTION_ID', 'Execution ID to retrieve coverage for') do |exid|
    options[:execution_id] = exid
  end
end.parse!

raise "You must run this from inside the Rails root. I can't find an 'app' directory here." unless Dir.exist?(File.join(FileUtils.pwd, 'app'))

execution_id = options[:execution_id]

raise "You must give an execution ID. I don't know what to retrieve coverage for without this.\n\nUsage: -e execution_id" if execution_id.nil?

username = ENV['CIDER_USERNAME']
password = ENV['CIDER_PASSWORD']

raise 'Please set CIDER_USERNAME and CIDER_PASSWORD.' if username.nil? or password.nil?

def fix_resultsets(resultsets)
  results = []
  resultsets.each do |resultset|
    resultset.each do |command_name, data|
      fixed_coverage_data = {}
      data['coverage'].each do |k, v|
        local_path = k.gsub(/\/.*\/[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}/, FileUtils.pwd)
        fixed_coverage_data[local_path] = v
      end
      data['coverage'] = fixed_coverage_data
      result = SimpleCov::Result.from_hash(command_name => data)
      results << result
    end
  end
  results
end

def stats(result)
  nils = 0
  not_run = 0
  run = 0
  result.values.each do |file|
    nils += file.count(nil)
    not_run += file.count(0)
    run += file.select {|line|
      line if !line.nil? and line > 0
    }.count
  end
  return "#{nils} nils, #{not_run} not run, #{run} run."
end

def merge_results(results)
  puts 'Merging results'
  merged = {}
  results.each_with_index do |result, index|
    puts "Seen #{result.original_result.keys.count} files in result set #{index} before merge. Stats: #{stats(result.original_result)}"
    merged = result.original_result.merge_resultset(merged)
  end
  puts "Seen #{merged.keys.count} files in results after merge. Stats: #{stats(merged)}."
  merged
end

cc = CiderClient.new(host: 'ci2.zhdk.ch',
                     username: username,
                     password: password)
cc.execution_id = execution_id

resultsets = []

puts "Gathering coverage data for execution #{cc.execution_id}."
cc.trial_attachment_hrefs(/.*resultset\.json$/).each do |tah|
  puts "Gathering results from #{tah}"
  resultsets << SimpleCov::JSON.parse(cc.attachment_data(tah))
end

results = fix_resultsets(resultsets)
merged = merge_results(results)

SimpleCov.add_group 'Models', 'app/models'
SimpleCov.add_group 'Controllers', 'app/controllers'
SimpleCov.add_group 'Views', 'app/views'
SimpleCov.add_group 'Helpers', 'app/helpers'
SimpleCov.add_group 'Factories', 'factories'
SimpleCov.add_group 'Libraries', 'lib'

result = SimpleCov::Result.new(merged)
result.command_name = results.map(&:command_name).sort.uniq.join(', ')
formatter = SimpleCov::Formatter::HTMLFormatter.new
formatter.format(result)
puts 'Done'
