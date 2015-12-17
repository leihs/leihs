module LeihsAdmin
  class StatisticsController < AdminController

    before_action do
      @statistics = ['Who borrowed the most things?',
                     'Which inventory pool is busiest?',
                     'Who bought the most items?',
                     'Which item is busiest?',
                     'Which model is busiest?',
                     'Which inventory pool has the most contracts?']

      params[:start_date] ||= I18n.l 30.days.ago.to_date
      params[:end_date] ||= I18n.l Time.zone.today
    end

    def index
    end

    def show
      @list = case params[:id]
              when 'Who borrowed the most things?'.parameterize
                  Statistics::Base.hand_overs([User, Model], params.to_hash)
              when 'Which inventory pool is busiest?'.parameterize
                  Statistics::Base.hand_overs([InventoryPool, Model],
                                              params.to_hash)
              when 'Who bought the most items?'.parameterize
                  Statistics::Base.item_values([InventoryPool, Model],
                                               params.to_hash)
              when 'Which item is busiest?'.parameterize
                  Statistics::Base.hand_overs([Item, User], params.to_hash)
              when 'Which model is busiest?'.parameterize
                  Statistics::Base.hand_overs([Model, Item], params.to_hash)
              when 'Which inventory pool has the most contracts?'.parameterize
                  Statistics::Base.contracts([InventoryPool, User], params.to_hash)
              else
                  redirect_to admin.statistics_path
              end
    end

  end

end
