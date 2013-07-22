# This file contains logic to initialize rubys global random generator with a
# fixed value before each scenario. The seed value is randomly chosen for each
# cucumber run. Alternatively, it can be injected via the CUCUMBER_RANDOM_SEED
# environment variable to reproduce results.

class CucumberRandom
  class << self 
    attr_accessor :seed
  end
end

AfterConfiguration  do |config|
  CucumberRandom.seed ||= ENV['CUCUMBER_RANDOM_SEED'].try(:to_i) || Random.new_seed % 10**7
  puts "CUCUMBER_RANDOM_SEED=#{CucumberRandom.seed}"
  Rails.logger.info "CUCUMBER_RANDOM_SEED=#{CucumberRandom.seed}"
  srand(CucumberRandom.seed)
end

Before do |scenario| 
  srand(CucumberRandom.seed)
end

at_exit do
  puts "CUCUMBER_RANDOM_SEED=#{CucumberRandom.seed}"
  Rails.logger.info "CUCUMBER_RANDOM_SEED=#{CucumberRandom.seed}"
end
