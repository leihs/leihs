class Admin::ApplicationController < ApplicationController

  layout 'manage'

  before_filter do
    not_authorized!(root_path) unless is_admin?
  end

  protected

  # TODO remove after separating admin and manage
  helper_method :current_managed_inventory_pools
  def current_managed_inventory_pools
    @current_managed_inventory_pools ||= (current_user.inventory_pools.managed - [current_inventory_pool]).sort
  end

end
