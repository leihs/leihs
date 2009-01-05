class Importer
  
  def start(max = 9999999)
    msg = InventoryImport::Importer.new.start(max)
    msg
  end
  
  def start_once
    InventoryImport::ImportOnce.new.start
  end
end