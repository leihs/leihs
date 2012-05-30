module Json
  module ContractHelper

    def hash_for_contract(contract, with = nil)
      h = {
        type: 'contract',
        id: contract.id,
        action: contract.action,
        status_const: contract.status_const
      }

      if with ||= nil
        [:quantity, :created_at, :updated_at, :inventory_pool_id, :note].each do |k|
          h[k] = contract.send(k) if with[k]
        end
      
        if with[:lines]
          h[:lines] = hash_for contract.lines, with[:lines]
        end
        if with[:user]
          h[:user] = hash_for contract.user, with[:user] 
        end
        if with[:inventory_pool]
          h[:inventory_pool] = hash_for contract.inventory_pool, with[:inventory_pool] 
        end
        if with[:barcode]
          require 'barby' 
          require 'barby/barcode/code_128' 
          require 'barby/outputter/png_outputter'
          with[:barcode] = {} unless with[:barcode].is_a?(Hash)
          with[:barcode][:height] ||= 25
          png = Barby::Code128B.new(" C #{contract.id}").to_png(:height => with[:barcode][:height].to_i)

          h[:barcode] = "data:image/png;base64,#{Base64.encode64(png)}"
        end
      end
      
      h
    end

  end
end
