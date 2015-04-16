module Statistics
  class Base
    class << self
  
      # Who borrowed the most things?
      # def most_borrower(date_range = nil)
      #   #Contract.select("user_id, count(*) as c").group_by(&:user_id).order_by("c desc").first
      #   Contract.group_by(&:user_id).first.first
      # end
  
      # Which inventory pool is busiest?
      # def busiest_inventory_pool
      #   Contract.group_by(&:inventory_pool_id).first.first
      # end
      
      # Who bought the most items?
      # def most_items_inventory_pool
      #   Item.all.group_by(&:inventory_pool_id).first.first
      # end
      
      # Which inventory pool costs the most money?
      # def most_money_inventory_pool
      #   nil
      # end
      
      #################################################

      def hand_overs(klasses, options = {})
        options.symbolize_keys!
        options[:limit] ||= 10

        if klasses.is_a? Array
          raise "limit is required" if options[:limit].nil?
          raise "max accepted limit is 20" if options[:limit] > 20
        end

        klasses = Array(klasses)
        klass = klasses.first
        klasses = klasses.drop(1)

        contract_lines = ContractLine.arel_table

        query = klass.unscoped.
                   select("#{klass.name.tableize}.id, SUM(contract_lines.quantity) AS quantity").
                   where(contract_lines[:type].eq("ItemLine").
                         and(contract_lines[:item_id].not_eq(nil)).
                         and(contract_lines[:returned_date].not_eq(nil))).
                   order("quantity DESC").
                   limit(options[:limit])

        query = case klass.name
          when "User"
            query.joins(:contract_lines).
              group("contract_lines.#{klass.name.foreign_key}").
              select("CAST(CONCAT_WS(' ', users.firstname, users.lastname) AS CHAR) AS label")
          when "InventoryPool"
            query.joins(:contract_lines).
              group("contract_lines.#{klass.name.foreign_key}").
              select("inventory_pools.name AS label")
          when "Model"
            query.joins(:contract_lines).
              group("contract_lines.#{klass.name.foreign_key}").
              select("CONCAT_WS(' ', models.manufacturer, models.product, models.version) AS label")
          when "Item"
            query.joins(:item_lines => :model).
                group("contract_lines.#{klass.name.foreign_key}").
                select("CONCAT_WS(' ', items.inventory_code, models.manufacturer, models.product, models.version) AS label")
          else
            raise "#{klass} not supported"
        end

        query = query.where(contract_lines: {user_id: options[:user_id]}) unless options[:user_id].blank?
        query = query.where(contract_lines: {inventory_pool_id: options[:inventory_pool_id]}) unless options[:inventory_pool_id].blank?
        query = query.where(contract_lines: {model_id: options[:model_id]}) unless options[:model_id].blank?
        query = query.where(contract_lines: {item_id: options[:item_id]}) unless options[:item_id].blank?
        query = query.where(contract_lines[:start_date].gteq(Date.parse(options[:start_date]).to_s(:db))) unless options[:start_date].blank?
        query = query.where(contract_lines[:returned_date].lteq(Date.parse(options[:end_date]).to_s(:db))) unless options[:end_date].blank?

        query.map do |x|
          h = { type: "statistic",
                object: klass.name,
                id: x.id,
                label: x.label,
                quantity: x.quantity.to_i,
                unit: _("lends") }
          h[:children] = hand_overs(klasses, options.merge({klass.name.foreign_key.to_sym => x.id})) unless klasses.empty?
          h
        end 
      end

      def contracts(klasses, options = {})
        options.symbolize_keys!
        options[:limit] ||= 10

        if klasses.is_a? Array
          raise "limit is required" if options[:limit].nil?
          raise "max accepted limit is 20" if options[:limit] > 20
        end

        klasses = Array(klasses)
        klass = klasses.first
        klasses = klasses.drop(1)

        contract_lines = ContractLine.arel_table

        query = klass.unscoped.
            select("#{klass.name.tableize}.id, COUNT(DISTINCT contracts.id) AS quantity").
            where(contract_lines: {status: [:signed, :closed]}).
            order("quantity DESC").
            limit(options[:limit])

        query = case klass.name
                  when "User"
                    query.joins(:contract_lines => :contract).
                        group("contract_lines.#{klass.name.foreign_key}").
                        select("CAST(CONCAT_WS(' ', users.firstname, users.lastname) AS CHAR) AS label")
                  when "InventoryPool"
                    query.joins(:contract_lines => :contract).
                        group("contract_lines.#{klass.name.foreign_key}").
                        select("inventory_pools.name AS label")
                  else
                    raise "#{klass} not supported"
                end

        query = query.where(contract_lines: {user_id: options[:user_id]}) unless options[:user_id].blank?
        query = query.where(contract_lines: {inventory_pool_id: options[:inventory_pool_id]}) unless options[:inventory_pool_id].blank?
        query = query.where(contract_lines: {model_id: options[:model_id]}) unless options[:model_id].blank?
        query = query.where(contract_lines: {item_id: options[:item_id]}) unless options[:item_id].blank?
        query = query.where(contract_lines[:start_date].gteq(Date.parse(options[:start_date]).to_s(:db))) unless options[:start_date].blank?
        query = query.where(contract_lines[:returned_date].lteq(Date.parse(options[:end_date]).to_s(:db))) unless options[:end_date].blank?

        query.map do |x|
          h = { type: "statistic",
                object: klass.name,
                id: x.id,
                label: x.label,
                quantity: x.quantity.to_i,
                unit: _("contracts") }
          h[:children] = contracts(klasses, options.merge({klass.name.foreign_key.to_sym => x.id})) unless klasses.empty?
          h
        end
      end

      def item_values(klasses, options = {})
        options.symbolize_keys!
        options[:limit] ||= 10

        if klasses.is_a? Array
          raise "limit is required" if options[:limit].nil?
          raise "max accepted limit is 20" if options[:limit] > 20
        end

        klasses = Array(klasses)
        klass = klasses.first
        klasses = klasses.drop(1)

        items = Item.arel_table

        query = klass.unscoped.
                   select("#{klass.name.tableize}.id, COUNT(items.id) AS quantity, SUM(items.price) AS price").
                   where(items[:price].gt(0)).
                   order("price DESC").
                   limit(options[:limit])

        query = case klass.name
          #when "User"
          #  query.joins(:contract_lines).
          #    group("contracts.#{klass.name.foreign_key}").
          #    select("CAST(CONCAT_WS(' ', users.firstname, users.lastname) AS CHAR) AS label")
          when "InventoryPool"
            query.joins(:own_items).
              group("items.owner_id").
              select("inventory_pools.name AS label")
          when "Model"
            query.joins(:items).
              group("items.#{klass.name.foreign_key}").
              select("models.product AS label")
          else
           raise "#{klass} not supported"
        end

        #query = query.where(:contracts => {:user_id => options[:user_id]}) if options[:user_id]
        query = query.where(items: {owner_id: options[:inventory_pool_id]}) unless options[:inventory_pool_id].blank?
        query = query.where(items: {model_id: options[:model_id]}) unless options[:model_id].blank?
        query = query.where(items[:created_at].gteq(Date.parse(options[:start_date]).to_s(:db))) unless options[:start_date].blank?
        query = query.where(items[:created_at].lteq(Date.parse(options[:end_date]).to_s(:db))) unless options[:end_date].blank?
        
        query.map do |x|
          h = { type: "statistic",
                object: klass.name,
                id: x.id,
                label: "#{x.quantity}x #{x.label}",
                quantity: x.price.to_i,
                unit: _("CHF") }
          h[:children] = item_values(klasses, options.merge({klass.name.foreign_key.to_sym => x.id})) unless klasses.empty?
          h
        end 
      end

    end
  end
end
