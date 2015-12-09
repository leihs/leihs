module LeihsAdmin
  class FieldsController < AdminController

    def index
      @grouped_fields = Field.unscoped.order(:position).sort_by do |f|
        [Field::GROUPS_ORDER.index(f.data['group']) || 999, f.position]
      end.group_by { |f| f.data['group'] }
    end

    def handle_new_fields
      new_fields = params[:fields].delete(:_new_fields_)

      unless new_fields.blank?
        new_fields.each do |param|
          Field.create do |r|
            r.id = param[:id]
            begin
              r.data = JSON.parse(param[:data])
            rescue => e
              @errors << format('%s: %s', field_id, e.to_s)
              next
            end
            if (r = check_attribute(r.data['attribute'], @item)).is_a? String
              @errors << r
              next
            end
            r.active = param[:active] == '1'
            r.position = i
          end
        end
      end
    end

    def handle_existing_fields
      i = 0
      params[:fields].each_pair do |field_id, param|
        i += 1
        field = Field.unscoped.find(field_id)
        begin
          data = JSON.parse(param[:data])
        rescue => e
          @errors << format('%s: %s', field_id, e.to_s)
          next
        end
        if (r = check_attribute(data['attribute'], @item)).is_a? String
          @errors << r
          next
        end
        field.update_attributes(data: data,
                                active: param[:active] == '1',
                                position: i)
      end
    end

    def update
      @errors = []
      @item = Item.new

      handle_existing_fields
      handle_new_fields

      if @errors.empty?
        flash[:success] = _('Saved')
        head status: :ok
      else
        render json: @errors, status: :internal_server_error
      end
    end

    private

    def check_attribute(attr, item)
      if attr.is_a?(Array)
        if attr.first == 'properties'
          # do nothing
        else
          target = item.send "build_#{attr.first}"
          unless target.respond_to? "#{attr.last}="
            return _('Unknown attribute %s') % attr.join('.')
          end
        end
      else
        unless item.respond_to? "#{attr}="
          return _('Unknown attribute %s') % attr
        end
      end
      true
    end
  end
end
