module Json
  module ApplicationHelper

    def json_for(target, with = nil)
      hash_for(target, with).to_json
    end

    def hash_for(target, with = nil)
      klass = target.class
      case klass.name
        when "Array", "ActiveRecord::Relation"
          target.map do |t|
            hash_for(t, with)
          end
        else
          send("hash_for_#{klass.name.underscore}", target, with)
      end
    end
    
    #################################################################

    def error_json(h)
      {
        error:{
          title: "Error", 
          text: h[:message]
        }
      }
    end

    #################################################################
    
    def results_json(results)
      with = {
        :user => {:city => true, :phone => true, :badge_id => true},
        :order => { :lines => {:model => {},
                               :dates => true},
                    :user => {:image_url => true,
                              :address => true,
                              :phone => true,
                              :email => true},
                    :quantity => true,
                    :created_at => true,
                    :updated_at => true,
                    :purpose => true},
        :contract => {:lines => {:model => {}},
                      :user => {:image_url => true},
                      :quantity => true,
                      :created_at => true,
                      :updated_at => true},
        :model => {:categories => {}, :availability => {:inventory_pool => current_inventory_pool}},
        :item => {:current_borrower => true, :current_return_date => true, :in_stock? => true, :is_broken => true, :is_incomplete => true, :model => {}},
        :option => {},
        :template => {}
      }
      
      results.map do |result|
        type = result.class.name.underscore
        hash_for result, with[type.to_sym]
      end.to_json
    end
    
  end
end
