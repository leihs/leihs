class Manage::VisitsController < Manage::ApplicationController
    
  def index
    respond_to do |format|
      format.html
      format.json {
        @visits = Visit.filter params, current_inventory_pool
        set_pagination_header(@visits) unless params[:paginate] == 'false'
      }
    end
  end

  def destroy
    visit = current_inventory_pool.visits.hand_over.find params[:visit_id]
    unless visit.blank?
      contract = visit.user.reservations_bundles.approved.find_by(inventory_pool_id: current_inventory_pool)
      Contract.transaction do
        visit.reservations.each { |l| contract.remove_line(l, current_user.id) }
      end
    end
    render status: :no_content, nothing: true
  end

  def remind
    visit = current_inventory_pool.visits.take_back.find params[:visit_id]

    # TODO dry with User.remind_and_suspend_all
    grouped_reservations = visit.reservations.group_by { |vl| {inventory_pool: vl.inventory_pool, user_id: (vl.delegated_user_id || vl.user_id)} }
    grouped_reservations.each_pair do |k, reservations|
      user = User.find(k[:user_id])
      user.remind(reservations, current_user)
    end

    render status: :no_content, nothing: true
  end

end
