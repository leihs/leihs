module LeihsAdmin
  class FieldsController < AdminController

    def index
      @grouped_fields = Field.unscoped.order(:position).sort_by do |f|
        [Field::GROUPS_ORDER.index(f.data['group']) || 999, f.position]
      end.group_by {|f| f.data['group'] }
    end

    def update
      def check_attribute(attr, item)
        if attr.is_a?(Array)
          if attr.first == 'properties'
            # do nothing
          else
            target = item.send "build_#{attr.first}"
            return _("Unknown attribute %s") % attr.join('.') unless target.respond_to? "#{attr.last}="
          end
        else
          return _("Unknown attribute %s") % attr unless item.respond_to? "#{attr}="
        end
        true
      end

      errors = []
      new_fields = params[:fields].delete(:_new_fields_)
      item = Item.new

      i = 0
      params[:fields].each_pair do |field_id, param|
        i += 1
        field = Field.unscoped.find(field_id)
        begin
          data = JSON.parse(param[:data])
        rescue => e
          errors << "%s: %s" % [field_id, e.to_s]
          next
        end
        if (r = check_attribute(data['attribute'], item)).is_a? String
          errors << r
          next
        end
        field.update_attributes(data: data, active: param[:active] == "1", position: i)
      end

      new_fields.each do |param|
        Field.create do |r|
          r.id = param[:id]
          begin
            r.data = JSON.parse(param[:data])
          rescue => e
            errors << "%s: %s" % [field_id, e.to_s]
            next
          end
          if (r = check_attribute(r.data['attribute'], item)).is_a? String
            errors << r
            next
          end
          r.active = param[:active] == "1"
          r.position = i
        end
      end unless new_fields.blank?

      if errors.empty?
        flash[:success] = _("Saved")
        head status: :ok
      else
        render json: errors,  status: :internal_server_error
      end
    end

  end

end
