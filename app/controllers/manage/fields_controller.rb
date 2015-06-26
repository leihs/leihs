class Manage::FieldsController < Manage::ApplicationController

  def index
    @fields = Field.all.select do |f|
      [params[:target_type], nil].include?(f.data['target_type']) and f.accessible_by?(current_user, current_inventory_pool)
    end.sort_by do |f|
      [Field::GROUPS_ORDER.index(f.data['group']) || 999, f.position]
    end
  end

  def hide
    current_user.hidden_fields.find_or_create_by(field_id: params[:id])
    render nothing: true, status: :ok
  end

  def reset
    current_user.hidden_fields.destroy_all
    render nothing: true, status: :ok
  end
end
