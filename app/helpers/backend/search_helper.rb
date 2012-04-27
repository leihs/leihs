module Backend::SearchHelper

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
    
    render(:partial => "backend/backend/search.json.rjson", :locals => {:results => results, :with => with})
  end

end