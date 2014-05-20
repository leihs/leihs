# FIXME not working properly when Timecop is traveling

Before do |scenario|
  # benchmark
  @time_before_scenario = Time.now.to_f
  @time_before_step ||= @time_before_scenario
end

After do |scenario|
  time_delayed = Time.now.to_f - @time_before_scenario
  Cucumber.logger.info "!!!! " if time_delayed > 30 # threshold in seconds
  Cucumber.logger.info "###### Scenario duration: %.2fs\n" % time_delayed
end

AfterStep do
  if @time_before_step
    time_delayed = Time.now.to_f - @time_before_step
    Cucumber.logger.info "!!!! " if time_delayed > 5 # threshold in seconds
    Cucumber.logger.info "###### Step duration: %.2fs" % time_delayed
  end
  @time_before_step = Time.now.to_f
end
