class Backend::BarcodesController < Backend::BackendController


  def index
    redirect_to :action => 'new'
  end

  def new
    if request.post?
      @string = params[:string]
      @height = params[:height]
      @height = 25 if @height.empty? or @height.nil?
      require 'barby'
      require 'barby/outputter/cairo_outputter'
      send_data(Barby::Code128B.new(@string.to_s).to_eps(:height => @height.to_f), :filename => "barcode_#{@string}.eps", :type => 'application/postscript')
    end
  end

end
