module BundleFinder
  def find(*args)
    return super if block_given?

    records = args.map do |arg|
      if arg.is_a? String and arg.include?('_')
        status, user_id, inventory_pool_id = arg.split('_')
        find_by(status: status, user_id: user_id, inventory_pool_id: inventory_pool_id)
      else
        find_by(contract_id: arg)
      end
    end
    if args.size != records.compact.size
      super
    else
      records.size == 1 ? records.first : records
    end
  end

  def where(*args)
    if args.first.is_a? Hash and arg = args.first.delete(:id)
      if arg.is_a? String and arg.include?('_')
        status, user_id, inventory_pool_id = arg.split('_')
        args.first.merge!({status: status, user_id: user_id, inventory_pool_id: inventory_pool_id})
      else
        args.merge!({contract_id: arg})
      end
    end

    super
  end

  def empty?
    to_a.count.zero?
  end
end
