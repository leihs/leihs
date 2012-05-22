class Backend::BarcodesController < Backend::BackendController

=begin #OLD CODE#
	def index
	  unless params[:string]
      redirect_to :action => 'new'
    else
      @string = params[:string]
      @height = 25
      require 'barby'
      require 'barby/outputter/cairo_outputter'
      #require 'barby/outputter/png_outputter'
      send_data(Barby::Code128B.new(@string.to_s).to_svg(:height => @height.to_f), :filename => "barcode_#{@string}.svg", :type => 'image/svg+xml')
    end
  end

  def new
  end
  
  def create
      @string = params[:string]
      @height = 25
      require 'barby'
      require 'barby/outputter/cairo_outputter'
      #require 'barby/outputter/png_outputter'
      send_data(Barby::Code128B.new(@string.to_s).to_svg(:height => @height.to_f), :filename => "barcode_#{@string}.svg", :type => 'image/svg+xml')
  end
=end
end
