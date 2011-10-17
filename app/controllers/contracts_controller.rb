class ContractsController < FrontendController

  before_filter :pre_load

  def show(sort =  params[:sort] || "model", dir =  params[:sort_mode] || "ASC")
    respond_to do |format|
        format.html
        require 'prawn/measurement_extensions'
        prawnto :prawn => { :page_size => 'A4', 
                            :left_margin => 25.mm,
                            :right_margin => 15.mm,
                            :bottom_margin => 15.mm,
                            :top_margin => 15.mm
                          }
      if params[:template] == "value_list"
        
        if @contract.status_const == Contract::SIGNED or @contract.status_const == Contract::CLOSED
          format.pdf { send_data(render(:template => 'contracts/value_list_for_items', :layout => false), :type => 'application/pdf', :filename => "value_list_for_items#{@contract.id}.pdf") }
        else
          format.pdf { send_data(render(:template => 'backend/contracts/value_list_for_models', :layout => false), :type => 'application/pdf', :filename => "maximum_value_list_#{@contract.id}.pdf") }
        end
        
      else
       format.pdf { send_data(render(:layout => false), :type => 'application/pdf', :filename => "contract_#{@contract.id}.pdf") }
      end
    end
  end

########################################################
  
  private
  
  def pre_load
      @contract = current_user.contracts.find(params[:id]) if params[:id]
  end  

end
