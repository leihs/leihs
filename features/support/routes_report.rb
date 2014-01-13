@@routes_scenarios = {}
@@current_scenario_name = nil
@@scenarios = {}

class ActionController::Base
  def route_spec
    Rails.application.routes.router.recognize(request) do |route, _|
      return route.path.spec.to_s.gsub("(.:format)", '')
    end
    #Rails.application.routes.recognize_path(request.fullpath, method: request.method)
  end

  around_filter :wrap_actions

  def wrap_actions
    t1 = Time.now.to_f
    yield
    t2 = Time.now.to_f
    k = {path: route_spec, method: request.method, format: request.format.to_sym}.to_json
    @@routes_scenarios[k] ||= {}
    @@routes_scenarios[k][@@current_scenario_name] ||= []
    @@routes_scenarios[k][@@current_scenario_name] << t2-t1
  end
end

at_exit do
  digest = Digest::MD5.hexdigest @@scenarios.to_json
  filepath = File.join(Rails.root, "features", "reports", "%s.json" % digest)
  File.open(filepath,"w") do |f|
    f.write({routes: @@routes_scenarios, scenarios: @@scenarios}.to_json)
  end
end

Before do |scenario|
  @@current_scenario_name = if scenario.respond_to? :scenario_outline
                              [scenario.scenario_outline.name, scenario.name].join(' ')
                            else
                              scenario.name
                            end
end

After do |scenario|
  k, l = if scenario.respond_to? :scenario_outline
           [[scenario.scenario_outline.name, scenario.name].join(' '), scenario.scenario_outline.location]
         else
           [scenario.name, scenario.location]
         end
  @@scenarios[k] = {location: l, status: scenario.status} # TODO ?? pending
end
