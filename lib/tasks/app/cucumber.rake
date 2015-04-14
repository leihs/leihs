namespace :app do
  namespace :cucumber do

    # From https://gist.github.com/778535
    # In turn based on http://www.natontesting.com/2010/01/11/updated-script-to-list-all-cucumber-step-definitions/
    # adapted by sellittf
    desc "List all available steps"
    task :steps do
      require 'hirb'
      extend Hirb::Console
      features_dir = "features"
      step_files = Dir.glob(File.join(features_dir, 'step_definitions', '**/*.rb'))

      results = []
      step_files.each do |step_file|
        File.new(step_file).read.each_line.each_with_index do |line, number|
          next unless line =~ /^\s*(?:Given|When|Then)\s+|\//
          res = /(?:Given|When|Then)[\s\(]*\/[\^](.*)[\$]\/([imxo]*)[\s\)]*do\s*(?:$|\|(.*)\|)/.match(line)
          next unless res
          matches = res.captures
          results << OpenStruct.new(
              steps: matches[0],
              args: matches[2]
          )
        end
      end

      table results.sort_by{|x| x.steps}, :resize => false, :fields => [:steps, :args]
      puts ""
    end

  end
end