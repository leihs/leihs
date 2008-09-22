class Importer
  
  def start(max = 9999999)
    msg = InventoryImport::Importer.new.start(max)
    msg
  end
  
  
end