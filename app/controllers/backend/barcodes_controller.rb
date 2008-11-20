class Backend::BarcodesController < Backend::BackendController

	def index
    redirect_to :action => 'new'
  end

  def new
  end

  def create
      @string = params[:string]
      @height = 25
      require 'barby'
      require 'barby/outputter/png_outputter'
      send_data(Barby::Code128B.new(@string.to_s).to_png(:height => @height.to_f), :filename => "barcode_#{@string}.png", :type => 'image/png')
  end

end
