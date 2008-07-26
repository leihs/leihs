module ExtScaffoldCoreExtensions
  module ActionController
    module Base

      protected

        def update_pagination_state_with_params!(restraining_model = nil)
          model_klass = (restraining_model.is_a?(Class) || restraining_model.nil? ? restraining_model : restraining_model.to_s.classify.constantize)
          pagination_state = previous_pagination_state(model_klass)
          pagination_state.merge!({
            :sort_field => (params[:sort] || pagination_state[:sort_field] || 'id').sub(/(\A[^\[]*)\[([^\]]*)\]/,'\2'), # fields may be passed as "object[attr]"
            :sort_direction => (params[:dir] || pagination_state[:sort_direction]).to_s.upcase,
            :offset => (params[:start] || pagination_state[:offset] || 0).to_i,
            :limit => (params[:limit] || pagination_state[:limit] || 9223372036854775807).to_i
          })
          # allow only valid sort_fields matching column names of the given model ...
          unless model_klass.nil? || model_klass.column_names.include?(pagination_state[:sort_field])
            pagination_state.delete(:sort_field)
            pagination_state.delete(:sort_direction)
          end
          # ... and valid sort_directions
          pagination_state.delete(:sort_direction) unless %w(ASC DESC).include?(pagination_state[:sort_direction])
    
          save_pagination_state(pagination_state, model_klass)
        end
        
        def options_from_pagination_state(pagination_state)
          find_options = { :offset => pagination_state[:offset],
                           :limit  => pagination_state[:limit] }
          find_options.merge!(
            :order => "#{pagination_state[:sort_field]} #{pagination_state[:sort_direction]}"
          ) unless pagination_state[:sort_field].blank?
    
          find_options
        end
                
        def options_from_search(restraining_model = nil)
          model_klass = (restraining_model.is_a?(Class) || restraining_model.nil? ? restraining_model : restraining_model.to_s.classify.constantize)
          returning options = {} do
            search_conditions = []
            unless [params[:fields], params[:query]].any?(&:blank?)
              ActiveSupport::JSON::decode(params[:fields]).each do |field|
                field.sub!(/(\A[^\[]*)\[([^\]]*)\]/,'\2') # fields may be passed as "object[attr]"
                next unless model_klass.nil? || model_klass.column_names.include?(field) # accept only valid column names
                search_conditions << "#{field} LIKE :query"
              end
            end
            
            options.merge!(:conditions => [search_conditions.join(' OR '),
                          {:query      => "%#{params[:query]}%"}]
                          ) unless search_conditions.empty?
          end
        end

      private

        # get pagination state from session
        def previous_pagination_state(model_klass = nil)
          session["#{model_klass.to_s.pluralize.underscore if model_klass}_pagination_state"] || {}
        end
    
        # save pagination state to session
        def save_pagination_state(pagination_state, model_klass = nil)
          session["#{model_klass.to_s.pluralize.underscore if model_klass}_pagination_state"] = pagination_state
        end

    end
  end
end