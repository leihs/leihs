# TODO remove this controller

class Admin::AccessRightsController < Admin::AdminController
  active_scaffold :access_right do |config|
    config.columns = [:inventory_pool, :user, :role]
    config.columns.each { |c| c.collapsed = true }

  end
  
  
end
