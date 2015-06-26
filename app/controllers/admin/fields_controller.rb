class Admin::FieldsController < Admin::ApplicationController

  def index
    @grouped_fields = Field.unscoped.order(:position).sort_by do |f|
      [Field::GROUPS_ORDER.index(f.data['group']) || 999, f.position]
    end.group_by {|f| f.data['group'] }
  end

  def update
    new_fields = params[:fields].delete(:_new_fields_)

    i = 0
    params[:fields].each_pair do |field_id, param|
      i += 1
      field = Field.unscoped.find(field_id)
      data = JSON.parse(param[:data]) # TODO validate parsed json
      field.update_attributes(data: data, active: param[:active] == "1", position: i)
    end

    new_fields.each do |param|
      Field.create do |r|
        r.id = param[:id]
        r.data = JSON.parse(param[:data]) # TODO validate parsed json
        r.active = param[:active] == "1"
        r.position = i
      end
    end unless new_fields.blank?

    redirect_to admin_fields_path, flash: {success: _("Saved")}
  end

end
