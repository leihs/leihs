class Manage::VisitsController < Manage::ApplicationController

  def index
    respond_to do |format|
      format.html
      format.json do
        visits = Visit.filter(params, current_inventory_pool)
        unless params[:paginate] == 'false'
          @visits = visits.default_paginate(params)
          # NOTE: `total_entries` from will_paginate gem does not
          # work with our custom `Visit.default_scope`, thus we
          # use our own `Visit.total_count_for_paginate`
          headers['X-Pagination'] = {
            total_count: visits.total_count_for_paginate,
            per_page: @visits.per_page,
            offset: @visits.offset
          }.to_json
        end
      end
    end
  end

  def destroy
    visit = current_inventory_pool.visits.hand_over
                .having('id = ?', params[:visit_id]).first
    unless visit.blank?
      contract = \
        visit
          .user
          .reservations_bundles
          .approved
          .find_by(inventory_pool_id: current_inventory_pool)
      Contract.transaction do
        visit.reservations.each { |l| contract.remove_line(l) }
      end
    end
    head status: :ok
  end

  def remind
    visit = current_inventory_pool.visits.take_back
                .having('id = ?', params[:visit_id]).first

    # TODO: dry with User.remind_and_suspend_all
    grouped_reservations = visit.reservations.group_by do |vl|
      { inventory_pool: vl.inventory_pool,
        user_id: (vl.delegated_user_id || vl.user_id) }
    end
    grouped_reservations.each_pair do |k, reservations|
      user = User.find(k[:user_id])
      user.remind(reservations)
    end

    head status: :ok
  end

end
