class Admin::UsersController < Admin::AdminController
  active_scaffold :user do |config|
    config.columns = [:login, :access_rights, :inventory_pools, :orders, :contracts]
    config.columns.each { |c| c.collapsed = true }

  end

  
end
