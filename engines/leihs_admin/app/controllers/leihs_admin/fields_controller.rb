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
            redirect_to :back, flash: {error: _("Unknown attribute %s") % attr.join('.')} and return false unless target.respond_to? "#{attr.last}="
          end
        else
          redirect_to :back, flash: {error: _("Unknown attribute %s") % attr} and return false unless item.respond_to? "#{attr}="
        end
        true
      end

      new_fields = params[:fields].delete(:_new_fields_)
      item = Item.new

      i = 0
      params[:fields].each_pair do |field_id, param|
        i += 1
        field = Field.unscoped.find(field_id)
        begin
          data = JSON.parse(param[:data])
        rescue => e
          #old# redirect_to :back, flash: {error: e.to_s} and return
          render text: e.to_s,  status: :internal_server_error and return
        end
        return unless check_attribute(data['attribute'], item)
        field.update_attributes(data: data, active: param[:active] == "1", position: i)
      end

      new_fields.each do |param|
        Field.create do |r|
          r.id = param[:id]
          begin
            r.data = JSON.parse(param[:data])
          rescue => e
            #old# redirect_to :back, flash: {error: e.to_s} and return
            render text: e.to_s,  status: :internal_server_error and return
          end
          return unless check_attribute(r.data['attribute'], item)
          r.active = param[:active] == "1"
          r.position = i
        end
      end unless new_fields.blank?

      flash[:success] = _("Saved")
      #old# redirect_to admin.fields_path
      head status: :ok
    end

  end

end
