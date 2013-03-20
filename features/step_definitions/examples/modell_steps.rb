# encoding: utf-8

Angenommen /^man öffnet die Liste der Modelle$/ do
  @current_inventory_pool = @current_user.managed_inventory_pools.first
  visit backend_inventory_pool_models_path @current_inventory_pool
end