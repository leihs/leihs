class Backend::CategoriesController < Backend::BackendController
  active_scaffold :category do |config|
    config.columns = [:name, :type, :models, :children, :parents]
    config.columns.each { |c| c.collapsed = true }

    config.actions.exclude :create, :update, :delete
end


end
  
