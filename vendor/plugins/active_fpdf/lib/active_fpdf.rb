require 'fpdf'

module ActiveFPDF
  
	class PDFRender < ActionView::Base
    	include ApplicationHelper

    	def initialize(action_view)
      		@action_view = action_view
    	end

	    def render(template, local_assigns = {})
      	#get the instance variables setup	    	
     		@action_view.controller.instance_variables.each do |v|
         		instance_variable_set(v, @action_view.controller.instance_variable_get(v))
        end
  			
  			#keep ie happy
  			if @action_view.controller.request.env['HTTP_USER_AGENT'] =~ /msie/i
          		@action_view.controller.headers['Pragma'] ||= ''
          		@action_view.controller.headers['Cache-Control'] ||= ''
     		else
          		@action_view.controller.headers['Pragma'] ||= 'no-cache'
          		@action_view.controller.headers['Cache-Control'] ||= 'no-cache, must-revalidate'
     		end
       		
       		
     		@action_view.controller.headers["Content-Type"] ||= 'application/pdf'
     		
  			if @rails_pdf_name
  				@action_view.controller.headers["Content-Disposition"] ||= 'attachment; filename="' + @rails_pdf_name + '"'
  			elsif @rails_pdf_inline
  				#set no headers
  			else
  				@time = Time.now.strftime("%y%m%d%H%M%S")  				
  				@action_view.controller.headers["Content-Disposition"] ||= 'attachment; filename="' + @action_view.controller.controller_name + "-" + @time + '.pdf' + '"'
  			end     
        
        @PDF_CLASS = "FPDF" if @PDF_CLASS.nil?
     		pdf = ApplicationHelper.const_get(@PDF_CLASS).new
        @tmpl = "#{@action_view.base_path}/#{@action_view.first_render}.#{@action_view.pick_template_extension(@action_view.first_render)}"
   	    eval template, nil, @tmpl
     		pdf.Output
    	end
  end

end
