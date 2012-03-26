module DataFactory 
  extend self

  def reset_data
    DatabaseAuthentication.delete_all
    User.delete_all
    Item.delete_all
    ModelGroup.delete_all
    Model.delete_all
    InventoryPool.delete_all
  end
end