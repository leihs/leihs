## 1903** Fix for Rails 2.3
#
## http://rails.lighthouseapp.com/projects/8994/tickets/2189
#
#module CountFix
#  def self.included(base)
#    base.class_eval do
#      extend ClassMethods
#      class << self; alias_method_chain :construct_count_options_from_args, :fix; end
#    end
#  end
#  
#  module ClassMethods
#    protected
#
#      def construct_count_options_from_args_with_fix(*args)
#        column_name, options = construct_count_options_from_args_without_fix(*args)
#        column_name = '*' if column_name =~ /\.\*$/
#        [column_name, options]
#      end
#
#  end
#end
#ActiveRecord::Base.send :include, CountFix