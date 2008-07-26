module ExtScaffoldCoreExtensions
  module ActiveRecord
    module Base

      def to_ext_json(options = {})
        success = options.delete(:success)
        # always transform attribute hash keys to model_name[attribute_name]
        if options.delete(:output_format) == :form_values
          # return array of id/value hashes for setValues, i.e.:
          #  [ {"value": 1, "id": "post[id]"},
          #    {"value": "First Post", "id": "post[title]"},
          #    {"value": "This is my first post.", "id": "post[body]"},
          #    {"value": true, "id": "post[published]"},
          #    ...
          #  ]          
          attributes.map{|name,value| { :id => "#{self.class.to_s.underscore}[#{name}]", :value => value } }.to_json(options)
        else
          if success || (success.nil? && valid?)
            # return sucess/data hash to form loader, i.e.:
            #  {"data": { "post[id]": 1, "post[title]": "First Post",
            #             "post[body]": "This is my first post.",
            #             "post[published]": true, ...},
            #   "success": true}
            { :success => true, :data => Hash[*attributes.map{|name,value| ["#{self.class.to_s.underscore}[#{name}]", value] }.flatten] }.to_json(options)
          else
            # return no-sucess/errors hash to form submitter, i.e.:
            #  {"errors":  { "post[title]": "Title can't be blank", ... },
            #   "success": false }
            error_hash = {}
            attributes.each do |field, value|
              if errors = self.errors.on(field)
                error_hash["#{self.class.to_s.underscore}[#{field}]"] = "#{errors.is_a?(Array) ? errors.first : errors}"
              end
            end
            { :success => false, :errors => error_hash }.to_json(options)
          end
        end
      end

    end
  end
end
