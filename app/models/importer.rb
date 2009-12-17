class Importer
  
  def start(max = 9999999)
    msg = InventoryImport::Importer.new.start(max)
    msg
  end
  
  def start_once(pool)
    InventoryImport::ImportOnce.new.start(pool)
  end
  
  def start_reservations_import(pool)
    InventoryImport::ImportReservations.new.start(pool)
  end
  
  def start_user_import
    InventoryImport::ImportUsers.new.start
  end

  def start_ithelp_import
    InventoryImport::ImportIthelp.new.start
  end

end