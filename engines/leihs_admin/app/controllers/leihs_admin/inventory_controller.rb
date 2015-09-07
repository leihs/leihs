module LeihsAdmin
  class InventoryController < AdminController

    def csv_export
      send_data InventoryPool.csv_export(nil, params),
                type: 'text/csv; charset=utf-8; header=present',
                disposition: "attachment; filename=#{_("Items-leihs")}.csv"
    end

  end

end
