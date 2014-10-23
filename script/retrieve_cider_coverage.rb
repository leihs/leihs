require 'rubygems'

require 'rest-client'
require 'json'
require 'simplecov'
require 'fileutils'
require 'optparse'
require 'pry'


options = {}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: retrieve_cider_coverage.rb [-c SHA] [-e EXECUTION_ID]"
  options[:commit_sha] = nil
  options[:execution_id] = nil

  opts.on('-c', '--commit COMMIT_SHA', 'Commit SHA to retrieve coverage for') do |sha|
    options[:commit_sha] = sha
  end

  opts.on('-e', '--execution EXECUTION_ID', 'Execution ID to retrieve coverage for') do |exid|
    options[:execution_id] = exid
  end
end.parse!


raise "You must run this from inside the Rails root. I can't find an 'app' directory here." unless Dir.exist?(File.join(FileUtils.pwd, "app"))

execution_id = options[:execution_id]
commit_sha = options[:commit_sha]

raise "You must give an execution ID or a commit SHA, I don't know what the hell to retrieve coverage for without this.\n\nUsage: [-c commit_sha] [-e execution_id]" if execution_id.nil? and commit_sha.nil?



username = ENV['CIDER_USERNAME']
password = ENV['CIDER_PASSWORD']

raise "Please set CIDER_USERNAME and CIDER_PASSWORD." if username.nil? or password.nil?

class CiderClient
  attr_accessor :execution_id, :commit_sha
  attr_writer :username, :password

  @execution_id = nil
  @commit_sha = nil
  @username = nil
  @password = nil


  def mode
    if @execution_id and not @commit_sha
      mode = "execution_id"
    elsif @commit_sha and not @execution_id
      mode = "commit_sha"
    end
    mode
  end

  def base_url
    return "http://#{@username}:#{@password}@ci2.zhdk.ch"
  end

  # URL starting from the base URL root, with the passed path appended
  def url(path)
    return "#{base_url}/#{path}"
  end

  def api_url(path)
    return url("/cider-ci/api/v1/#{path}")
  end

  # URL starting from the execution, with the passed path appended
  def execution_url(path)
    return api_url("execution/#{@execution_id}/#{path}")
  end

  def recurse_tasks(tasks, data)
    if data["_links"]["cici:task"]
      tasks = tasks.concat(data["_links"]["cici:task"])
    end
    if data["_links"]["next"]
      puts "Retrieved #{tasks.count} tasks total so far."
      data = JSON.parse(RestClient.get(url(data["_links"]["next"]["href"])))
      tasks = recurse_tasks(tasks, data)
    end
    tasks
  end

  def tasks
    tasks = []
    tasks = recurse_tasks(tasks, JSON.parse(RestClient.get(execution_url("tasks"))))
  end

  def trials
    trials = []
    tasks.each do |task|
      task_url = url(task['href'])
      details = JSON.parse(RestClient.get(task_url))
      trials_url = url(details["_links"]["cici:trials"]["href"])
      puts "Need to retrieve all trials for #{details["_links"]["cici:trials"]["href"]}"
      single_trial = JSON.parse(RestClient.get(trials_url))
      single_trial["_links"]["cici:trial"].each do |st|
        trials << st
      end
    end
    trials
  end

  def tree_id_from_commit(commit_sha)
    `git show #{commit_sha} --format=%T | head -1`.chomp
  end

  def tree_attachment_groups
    tree_id = tree_id_from_commit(self.commit_sha)
    tree_attachment_groups = []
    tree_attachments = JSON.parse(RestClient.get(api_url("tree-attachments/#{tree_id}")))
    binding.pry
    puts "foo"

  end

  def tree_attachment_hrefs(pattern = /.*/)
    matching_tas = []
    tree_attachment_groups.each do |ta|
      tree_attachment_url = url(ta["href"])
      tree_attachment_details = JSON.parse(RestClient.get(tree_attachment_url))
      matching_tas << tree_attachment_details["_links"]["cici:tree-attachment"].select {|ta|
        ta if ta["href"].match(pattern)
      }
    end
    matching_tas.flatten.map {|ta|
      ta["href"]
    }
  end

  def trial_attachment_groups
    puts "Retrieving trial details to find all attachments, this may take a long time."
    trial_attachment_groups = []
    trials.each do |trial|
      trial_url = url(trial["href"])
      puts "Retrieving trial details for #{trial_url}."
      single_trial = JSON.parse(RestClient.get(trial_url))
      trial_attachment_groups << single_trial["_links"]["cici:trial-attachments"]
    end
    trial_attachment_groups
  end

  # Takes a regex pattern and returns only hrefs of the attachments that matched the regex.
  def trial_attachment_hrefs(pattern = /.*/)
    matching_tas = []
    trial_attachment_groups.each do |ta|
      trial_attachment_url = url(ta["href"])
      trial_attachment_details = JSON.parse(RestClient.get(trial_attachment_url))
      matching_tas << trial_attachment_details["_links"]["cici:trial-attachment"].select {|ta|
        ta if ta["href"].match(pattern)
      }
    end
    matching_tas.flatten.map {|ta|
      ta["href"]
    }
  end

  def trial_attachment_data(href)
    trial_attachment_details = JSON.parse(RestClient.get(url(href)))
    stream_url = trial_attachment_details["_links"]["data-stream"]["href"]
    stream_url.gsub!("https://195.176.254.43", base_url)
    RestClient.get(stream_url)
  end
end

def fix_resultsets(resultsets)
  results = []
  resultsets.each do |resultset|
    resultset.each do |command_name, data|
      fixed_coverage_data = {}
      data["coverage"].each do |k, v|
        local_path = k.gsub(/\/.*\/[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}/, FileUtils.pwd)
        fixed_coverage_data[local_path] = v
      end
      data["coverage"] = fixed_coverage_data
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
  puts "Merging results"
  merged = {}
  results.each_with_index do |result, index|
    puts "Seen #{result.original_result.keys.count} files in result set #{index} before merge. Stats: #{stats(result.original_result)}"
    merged = result.original_result.merge_resultset(merged)
  end
  puts "Seen #{merged.keys.count} files in results after merge. Stats: #{stats(merged)}."
  merged
end

cc = CiderClient.new
binding.pry
cc.username = username
cc.password = password
cc.commit_sha = commit_sha
cc.execution_id = execution_id

resultsets = []

if cc.mode == "execution_id"
  puts "Gathering coverage data for execution #{cc.execution_id}."
  cc.trial_attachment_hrefs(/.*resultset\.json$/).each do |tah|
    puts "Gathering results from #{tah}"
    resultsets << SimpleCov::JSON.parse(cc.trial_attachment_data(tah))
  end
elsif cc.mode == "commit_sha"
  cc.tree_attachment_hrefs(/.*resultset\.json$/).each do |tah|
    puts "Gathering results from #{tah}"
    resultsets << SimpleCov::JSON.parse(cc.tree_attachment_data(tah))
  end
end

results = fix_resultsets(resultsets)
merged = merge_results(results)

SimpleCov.add_group "Models", "app/models"
SimpleCov.add_group "Controllers", "app/controllers"
SimpleCov.add_group "Views", "app/views"
SimpleCov.add_group "Helpers", "app/helpers"
SimpleCov.add_group "Factories", "factories"
SimpleCov.add_group "Libraries", "lib"

result = SimpleCov::Result.new(merged)
result.command_name = results.map(&:command_name).sort.uniq.join(", ")
formatter = SimpleCov::Formatter::HTMLFormatter.new
formatter.format(result)
puts "Done"
