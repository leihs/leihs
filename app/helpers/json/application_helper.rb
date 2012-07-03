module Json
  module ApplicationHelper

    def json_for(target, with = nil)
      hash_for(target, with).to_json
    end

    def hash_for(target, with = nil)
      klass = target.class
      case klass.name
        when "Array", "ActiveRecord::Relation", "WillPaginate::Collection"
          target.map do |t|
            hash_for(t, with)
          end
        else
          with = {} if with == true
          with = get_with_preset(with[:preset]).deep_merge(with) if not with.nil? and with[:preset]
          send("hash_for_#{klass.name.underscore}", target, with)
      end
    end
    
    #################################################################
    # TODO merge success and error json

    def error_json(h)
      {
        error:{
          title: h[:title] || _("Error"),
          text: h[:message]
       }
      }
    end

    def success_json(h)
      {
        success:{
          title: h[:title] || _("Success"),
          text: h[:message]
       }
      }
    end

    #################################################################
    
    def results_json(results)
      with = {
        :user => {:image_url => true, :email => true, :address => true, :zip => true, :city => true, :phone => true, :badge_id => true},
        :order => { :lines => {:model => {},
                               :dates => true},
                    :user => {:image_url => true, :email => true, :address => true, :zip => true, :city => true, :phone => true, :badge_id => true},
                    :quantity => true,
                    :created_at => true,
                    :updated_at => true,
                    :purpose => true},
        :contract => {:lines => {:model => {}},
                      :user => {:image_url => true, :email => true, :address => true, :zip => true, :city => true, :phone => true, :badge_id => true},
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

    #################################################################

    def get_with_preset(key)
      case key
        when "inventory"
          {:image_thumb => true,
           :inventory_code => true, # for options
           :price => true, # for options
           :is_package => true,
           :items => {
                      :current_borrower => true,
                      :current_return_date => true,
                      :in_stock? => true,
                      :is_broken => true,
                      :is_incomplete => true,
                      :location => true,
                      :inventory_pool => true,
                      :children => {:model => {}}
                     },
           :availability => {:inventory_pool => current_inventory_pool},
           :categories => {}}
      end
    end

  end
end
