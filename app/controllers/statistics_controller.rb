class StatisticsController < ActionController::Base

  def show
  end

  def activities(type = params[:type],
                 id = params[:id])
                 
    Audit.unscoped do
      @activities = if type and id             
        target = type.camelize.constantize.find(id)                 
        target.audits.order("created_at DESC").flat_map {|x| Audit.where(:thread_id => x.thread_id).order("created_at DESC") }
      else
        Audit.order("created_at DESC").all
      end.group_by {|x| x.thread_id}
    end
    
    respond_to do |format|
      format.html
      format.json {
        #render :json => @activities
      }                  
    end
  end 

end
