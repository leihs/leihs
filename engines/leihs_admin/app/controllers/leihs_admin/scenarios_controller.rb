module LeihsAdmin
  class ScenariosController < AdminController

    def index
      dir = File.join(Rails.root, 'features', 'reports')
      merged_file = File.join(dir, 'merged_report.json')
      @routes_scenarios = if File.exists?(merged_file)
                            JSON.load(File.new(merged_file))
                          else
                            merged_report = Dir.glob(File.join(dir, '*.json')).inject({}) do |h, jsonfile|
                              h.deep_merge JSON.load(File.new(jsonfile))
                            end
                            File.open(merged_file, 'w') do |f|
                              f.write(merged_report.to_json)
                            end
                            merged_report
                          end
    end

  end

end
