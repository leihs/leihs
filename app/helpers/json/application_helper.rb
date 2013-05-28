module Json
  module ApplicationHelper

    def json_for(target, with = nil)
      hash_for(target, with).to_json
    end

    def hash_for(target, with = nil)
      klass = target.class
      case klass.name
        when "Array", "ActiveRecord::Relation", "WillPaginate::Collection"
          if with and with[:preset] and i = get_eager_preset(with[:preset])
            target = target.includes(i)
          end
          target.map do |t|
            hash_for(t, with)
          end
        else
          with = {} if with == true # FIXME is this still used ??
          with = get_with_preset(with[:preset]).deep_merge(with) if not with.nil? and with[:preset]
          with = with.try(:deep_symbolize_keys)
          send("hash_for_#{klass.name.underscore}", target, with)
      end
    end
    
    #################################################################

    def error_json(h)
      {
        error:{
          title: h[:title] || _("Error"),
          text: h[:message]
       }
      }
    end

    #################################################################
    
    def search_results_json(results, with)
      results.map do |result|
        type = result.class.name.underscore
        with = get_with_preset("#{type}_search").deep_merge(with) if with and with[:search_presets] and with[:search_presets].include?("#{type}_search".to_sym)
        hash_for result, with
      end.to_json
    end

    #################################################################

    def get_eager_preset(key)
      case key.to_sym
        when :order_minimal
          {:user => nil,
           :order_lines => :model}
        when :visit
          {:user => :reminders,
           :contract_lines => :model}
        when :hand_over_visit
          {:contract_lines => [:item, :model]}
      end
    end

    def get_with_preset(key)
      case key.to_sym
        when :modellist
          {
            image_thumb: true,
            is_destroyable: true
          }
        when :item_edit
         { :current_borrower => true,
           :current_return_date => true,
           :in_stock? => true,
           :inventory_pool => true,
           :invoice_date => true,
           :invoice_number => true,
           :is_borrowable => true,
           :is_broken => true,
           :is_incomplete => true,
           :is_inventory_relevant => true,
           :last_check => true,
           :location => true,
           :model => true,
           :name => true,
           :note => true,
           :owner => true,
           :price => true,
           :properties => true,
           :responsible => true,
           :retired => true,
           :retired_reason => true,
           :serial_number => true,
           :supplier => true,
           :user_name => true}
        when :inventory
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
                      :location_as_string => true,
                      :inventory_pool => true,
                      :owner => true,
                      :children => {:model => {}}
                     },
           :availability => {:inventory_pool => current_inventory_pool},
           :categories => {}}
        when :model
          {:is_editable => true,
           :is_destroyable => true,
           :is_package => true,
           :description => true,
           :technical_detail => true,
           :compatibles => {},
           :internal_description => true,
           :hand_over_note => true,
           :images => {},
           :packages => {:in_stock => true, :children => {:model => true}, :preset => :item_edit},
           :is_package => {},
           :max_partition_capacity => current_inventory_pool.id,
           :attachments => {},
           :properties => {},
           :partitions => {:group => true},
           :accessories => {}}
        when :order_minimal
          {:user => {:preset => :user},
           :purpose => {},
           :created_at => true,
           :updated_at => true,
           :quantity => true,
           :lines => {:model => {}, 
                      :dates => true,
                      :quantity => true}
          }
        when :order
          {:lines => {:preset => :order_line},
           :user => {:groups => true},
           :quantity => true,
           :purpose => true }
        when :order_line
          {:model => {},
           :order => {:user => {:groups => true}}, # FIXME remove this, we already have it as parent (used in line.js.coffee.erb @get_user)
           :availability_for_inventory_pool => true,
           :dates => true,
           :quantity => true,
           :is_available => true}
         when :contract
           {:barcode => true,
            :note => true,
            :inventory_pool => {:address => {}},
            :lines => {:item => {:price => true},
                       :model => {},
                       :purpose => {},
                       :returned_date => true},
            :user => {:address => true,
                      :zip => true,
                      :city => true},
            :handed_over_by_user => {} }
          when :contract_line
            {:is_valid => true,
             :item => {:is_borrowable => true, :is_broken => true, :is_incomplete => true},
             :model => {},
             :contract => {:user => {:groups => {}}}, # FIXME remove this, get it through parent contract (used in line.js.coffee.erb @get_user)
             :purpose => true,
             :availability => true}
          when :hand_over_line
            {:is_valid => true,
             :item => {:is_borrowable => true, :is_broken => true, :is_incomplete => true},
             :model => {:hand_over_note => true},
             :contract => {:user => {:groups => {}}}, # FIXME remove this, get it through parent contract (used in line.js.coffee.erb @get_user)
             :purpose => true,
             :availability => true}
          when :take_back_line
            {:is_valid => true,
             :item => {:is_borrowable => true, :is_broken => true, :is_incomplete => true},
             :model => {},
             :contract => {:user => {:groups => {}}}, # FIXME remove this, get it through parent contract (used in line.js.coffee.erb @get_user)
             :purpose => true,
             :availability => true}
          when :user
            {:image_url => true,
             :email => true,
             :address => true,
             :zip => true,
             :city => true,
             :country => true,
             :phone => true,
             :badge_id => true}
          when :visit_with_availability
            {:lines => {:preset => :contract_line}}
          when :hand_over_visit
            {:lines => {:preset => :hand_over_line}}
          when :take_back_visit
            {:lines => {:preset => :take_back_line}}
          when :visit
            {:user => {:preset => :user},
             :lines => {:model => {}, 
                        :dates => true,
                        :quantity => true},
             :quantity => true,
             :is_overdue => true}

          when :user_search
            {:preset => :user}
          when :order_search
            { :lines => {:model => {},
                         :dates => true},
              :user => {:preset => :user},
              :quantity => true,
              :created_at => true,
              :updated_at => true,
              :purpose => true}
          when :contract_search
            { :lines => {:model => {}},
              :user => {:preset => :user},
              :quantity => true,
              :created_at => true,
              :updated_at => true}
          when :model_search
            {:categories => {}, :availability => {:inventory_pool => current_inventory_pool}}
          when :item_search
            {:inventory_pool => true, :location_as_string => true, :current_borrower => true, :current_return_date => true, :in_stock? => true, :is_broken => true, :is_incomplete => true, :model => {}}
          when :option_search
            {}
          when :template_search
            {}
      end
    end

  end
end
