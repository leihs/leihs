
#@exportable_items = Item.all
@exportable_items = Item.find(:conditions => { :inventory_code  })

@exportable_items = Item.find(:all, :conditions => ["inventory_code LIKE ?", "AVZ%"])

item_array = []
item_array << ['inventory_code', 
      'inventory_pool',
      'serial_number', 
      'model_name', 
      'borrowable',
      'owner',
      'categories',
      'required_level',
      'invoice_number',
      'invoice_date',
      'last_check',
      'retired',
      'retired_reason',
      'price',
      'is_broken',
      'is_incomplete',
      'is_borrowable',
      'created_at',
      'updated_at',
      'needs_permission',
      'is_inventory_relevant',
      'responsible',
      'supplier']

@exportable_items.each do |i|
    puts "Trying item " + i.inventory_code.to_s + " (ID: " + i.id.to_s + ")"

    if i.inventory_pool.nil? or i.inventory_pool.name.blank?
      ip = "UNBEKANNT"
    else
      ip = i.inventory_pool.name 
    end

    if i.model.nil? or i.model.name.blank?
    mod = "UNBEKANNT/VERAENDERT"
    else
    mod = i.model.name.gsub(/\"/, '""')
    end

    if i.owner.nil? or i.owner.name.blank?
    own = "UNBEKANNT"
    else
      own = i.owner.name
    end

    unless i.model.categories.nil? or i.model.categories.count == 0
      categories = []
      i.model.categories.each do |c|
        categories << c.name + "|"
      end
    end
    
    if i.supplier.blank?
      supplier = "UNBEKANNT"
    else
      supplier = i.supplier.name
    end
    
    item_array << [ i.inventory_code,
      ip,                 
      i.serial_number,
      mod,
      i.is_borrowable,
      own,
      categories,
      i.required_level,
      i.invoice_number,
      i.invoice_date,
      i.last_check,
      i.retired,
      i.retired_reason,
      i.price,
      i.is_broken,
      i.is_incomplete,
      i.is_borrowable,
      i.created_at,
      i.updated_at,
      i.needs_permission,
      i.is_inventory_relevant,
      i.responsible,
      supplier
    ]

end




require 'csv'
CSV.open("/tmp/alle_mit_avz_nummern.csv","w", { :col_sep => ";", :quote_char => "\"", :force_quotes => true } ) do |csv|
  item_array.each do |i|
    csv << i
  end
end
