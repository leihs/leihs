class Admin::StatisticsController < Admin::ApplicationController

  def show
    @list_1 = Statistics::Base.hand_overs([User, Model], params.to_hash)
    @list_2 = Statistics::Base.hand_overs([InventoryPool, Model], params.to_hash)
    @list_3 = Statistics::Base.item_values([InventoryPool, Model], params.to_hash)
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
        render :json => {
            timeline: {
                headline:"The Main Timeline Headline Goes here",
                type:"default",
                startDate: @activities.first.last.first.try(:created_at).strftime("%Y,%m,%d"),
                text:"<p>Intro body text goes here, some HTML is ok</p>",
                asset: {
                        media:"http://yourdomain_or_socialmedialink_goes_here.jpg",
                        credit:"Credit Name Goes Here",
                        caption:"Caption text goes here"
                    },
                date: @activities.map do |activity|
                        audits = activity.last 
                        {
                          startDate: audits.first.try(:created_at).strftime("%Y,%m,%d,%H,%M,%S"),
                          headline: audits.first.try(:user).to_s,
                          text:"<p>Body text goes here, some HTML is OK</p>",
                          asset:
                          {
                              media: render(:partial => "activity.html", :locals => {:audits => audits}),
                              credit:"Credit Name Goes Here",
                              caption:"Caption text goes here"
                          }
                        }
                      end
            }
        }
      }                  
    end
  end 

end
