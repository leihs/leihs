class Backend::CategoriesController < Backend::BackendController
  active_scaffold :category do |config|
    config.columns = [:name, :type, :models, :children, :parents]
  end

#  active_scaffold :accounts do |config|
#    config.columns = [:number, :company, :contact_person, :money_balance, :debtor, :paper, :user, :transactions]
#    config.show.columns.add :created_at, :updated_at
#    
#    config.list.sorting = [{ :money_balance => :desc}, { :number => :asc }]
#    
#    config.create.columns.exclude :number, :money_balance
#    config.update.columns.exclude :number, :money_balance
#    
#    config.columns.each do |c|
#      c.collapsed = true
#    end 
#  end
#
#  active_scaffold :transactions do |config|
#    config.actions.exclude :update, :delete
#    
#    config.list.sorting = { :created_at => :desc }
#  end
#
#  active_scaffold :users do |config|
#    config.columns = [:nickname, :active, :accounts]
#    config.show.columns.add :created_at
#    
#    config.create.columns.add :crypted_password
#    config.update.columns.add :crypted_password
#    
#    config.columns.each do |c|
#      c.collapsed = true
#    end  
#  end    


end
  
