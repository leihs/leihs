class Admin::UsersController < Admin::AdminController
  active_scaffold :user do |config|
    config.columns = [:login, :access_rights, :inventory_pools, :orders, :contracts]
    config.columns.each { |c| c.collapsed = true }

  end


###############################################################

  def admins
    render :inline => "<%= render :active_scaffold => 'admin/users', :collection => User.admins %>", # TODO optimize conditions
           :layout => $general_layout_path    
  end
  
  def managers
    render :inline => "Managers <hr /> <%= render :active_scaffold => 'admin/users', :conditions => ['users.id IN (?)', User.managers] %>", # TODO optimize conditions
           :layout => $general_layout_path        
  end
  
  def students
    render :inline => "Students <hr /> <%= render :active_scaffold => 'admin/users', :conditions => ['users.id IN (?)', User.students] %>", # TODO optimize conditions
           :layout => $general_layout_path        
  end
  
end
