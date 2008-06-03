class Importer
  
  def start(max = 9999999)
    InventoryImport::Importer.new.start(max)
  end
  
end