class MergeDuplicatedSuppliers < ActiveRecord::Migration

  def change

    Supplier.all.select{|s| s.name.blank? }.each do |supplier|
      supplier.items.update_all(supplier_id: nil)
      supplier.destroy
    end

    Supplier.all.group_by {|s| s.name.downcase }.select {|k,v| v.size > 1}.each_pair do |k,v|
      keep_supplier = v.sort_by {|x| x.items.count }.last
      v.each do |supplier|
        next if supplier == keep_supplier
        supplier.items.update_all(supplier_id: keep_supplier.id)
        supplier.destroy
      end
    end

    change_column_null :suppliers, :name, false

    change_table :suppliers do |t|
      t.index   :name, unique: true
    end

  end

end
