class Backend::InventoryImport::ImporterController < ApplicationController
  def start
    imp = Importer.new
    @messages = imp.start
  end
end
