require 'ci_feature_jobs'

namespace :app do

  namespace :ci do

    # the default logger will not log to stdout, not very useful for rake tasks
    task :initialize => :environment do
      #$stdout.sync = true unless Rails.env == 'production'
      Rails.logger = Logger.new($stdout) 
      Rails.logger.formatter = Class.new(::Logger::Formatter) do
        def call(severity, timestamp, progname, msg)
          "[#{severity}] #{String === msg ? msg : msg.inspect}\n"
        end
      end.new()

      Rails.logger.level = Logger::INFO
      Rails.logger.info "Reitialized the logger, all logging goes to stdout, nowhere else!"
    end

    desc "Create the aggregator, create, respec and template of a new branch to be tested, requires BRANCH_NAME, CI_USER and CI_PW  env variables"
    task :create_branch => :initialize do
      Rails.logger.warn "depending on the mood of Jenkins: CALL THIS TASK TWICE!"
      begin
        CIFeatureJobs.create_new_job_aggregtor! ENV['BRANCH_NAME']
        CIFeatureJobs.create_new_job_creator! ENV['BRANCH_NAME']
        CIFeatureJobs.create_new_job_template! ENV['BRANCH_NAME']
        CIFeatureJobs.create_or_update_rspec_job! ENV['BRANCH_NAME']
      rescue => e
        Rails.logger.error e
      end
    end

    desc "Delete jobs by matching a regular expression; requires REX, CI_USER and CI_PW env variables" 
    task :delete_jobs_by_regex => :initialize do

      raise "you must provide non empty REX parameter"  unless rex=ENV['REX'] and (not rex.empty?)

      jobs = CIFeatureJobs.filter_jobs_by_regex rex
      if jobs.size < 1
        puts "no job mached your query, so I don't do anything"
      else
        puts jobs.map{|j| j['name']}.join("\n")
        puts "Confirm the deletion of the #{jobs.size} listed jobs by typing YES"
        if /^YES/ =~  STDIN.gets
          puts "Start deleting jobs..."
          res = CIFeatureJobs.delete_jobs jobs 
          puts res.map{|job| "#{job[:status]} #{job['name']}"}.join("\n")
        end
      end
    end

    desc "Updates and (creates when needed) all feature jobs; requires CI_USER and CI_PW env variables, or a AUTH_FILE and also BRANCH_NAME"
    task :create_or_update_all_feature_jobs => :initialize do
      opts = 
        begin 
          YAML::load_file(ENV['AUTH_FILE']).symbolize_keys
        rescue 
          {}
        end
      CIFeatureJobs.create_or_update_all_jobs! opts
    end

    desc "Checks if rspec all feature have been built successfully, requires BRANCH_NAME, CI_USER and CI_PW  env variables" 
    task :query_all_success => :initialize do
      opts = YAML::load_file(ENV['AUTH_FILE']).symbolize_keys rescue {}
      last_job_builds = CIFeatureJobs.get_last_build_status_of_all_feature_jobs(opts)
      begin 
        if CIFeatureJobs.all_features_success?(last_job_builds) and CIFeatureJobs.rspec_success?(opts)
          puts "all jobs have been build successfully"
          exit 0
        else
          Rails.logger.error "some jobs failed:"
          Rails.logger.error last_job_builds.select{|h| not h[:is_success]}.to_yaml
          exit -1
        end
      rescue => e
        Rails.logger.error e
        exit -1
      end
    end

  end
end
