class CreateRole < ActiveRecord::Migration

  def self.up    
    a = Role.find_by_name('admin')

    i = Role.create(:name => 'inventory manager')
    i.move_to_child_of(a)

    l = Role.find_by_name('manager')
    l.update_attributes(:name => "lending manager")
    l.move_to_child_of(i)
  end
  
  def self.down
  end
end
