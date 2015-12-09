module BarcodeHelper

  def barcode_for_contract(contract, height = 25)
    require 'barby'
    require 'barby/barcode/code_128'
    require 'barby/outputter/png_outputter'
    png = Barby::Code128B.new(" C #{contract.id}").to_png(height: height.to_i)
    "data:image/png;base64,#{Base64.encode64(png)}"
  end

end
