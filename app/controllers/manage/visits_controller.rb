class Manage::VisitsController < Manage::ApplicationController
    
  def index
    @visits = Visit.filter params, current_inventory_pool
    set_pagination_header(@visits) unless params[:paginate] == "false"
  end

  def destroy
    visit = current_inventory_pool.visits.hand_over.find params[:visit_id]
    unless visit.blank?
      contract = visit.user.approved_contract(current_inventory_pool)
      contract.remove_lines(visit.lines, current_user.id)
    end
    render :status => :no_content, :nothing => true
  end

  def remind
    visit = current_inventory_pool.visits.take_back.find params[:visit_id]

    # TODO dry with User.remind_and_suspend_all
    grouped_visit_lines = visit.visit_lines.group_by { |vl| {inventory_pool: vl.inventory_pool, user_id: (vl.delegated_user_id || vl.user_id)} }
    grouped_visit_lines.each_pair do |k, visit_lines|
      user = User.find(k[:user_id])
      user.remind(visit_lines, current_user)
    end

    render :status => :no_content, :nothing => true
  end

end
