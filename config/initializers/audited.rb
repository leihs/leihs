if ActiveRecord::Base.connection.tables.include?('audits')
  class ActiveRecord::Base
    class << self
      def inherited_with_auditing(subclass)
        inherited_without_auditing(subclass)
        subclass.class_eval { audited }
      end

      alias_method_chain :inherited, :auditing
    end
  end
end
