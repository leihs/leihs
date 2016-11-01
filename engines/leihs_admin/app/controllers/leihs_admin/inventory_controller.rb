module LeihsAdmin
  class InventoryController < AdminController

    def csv_export
      send_data InventoryPool.csv_export(nil, params),
                type: 'text/csv; charset=utf-8; header=present',
                disposition: "attachment; filename=#{_('Inventory')}.csv"
    end

    def excel_export
      send_data InventoryPool.excel_export(nil, params),
                type: 'application/xlsx',
                disposition: "filename=#{_('Inventory')}.xlsx"
    end

  end

end
