require 'domina'

module Domina
  module System
    class << self

      def execute_cmd! cmd
        puts "executing: `#{cmd}`"
        output = `#{cmd}`
        raise "ERROR executing `#{cmd}`" if $?.exitstatus != 0
        output
      end


    end
  end
end
