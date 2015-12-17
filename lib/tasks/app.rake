namespace :app do

  desc 'Build Railroad diagrams (requires peterhoeg-railroad 0.5.8 gem)'
  task :railroad do
    `railroad -iv -o doc/diagrams/railroad/controllers.dot -C`
    `railroad -iv -o doc/diagrams/railroad/models.dot -M`
  end

  desc "Revert item prices using audits (i.e. wrong 1.0, correct 1'234.50)"
  task revert_item_prices: :environment do
    fixed_items = []
    Audited::Adapters::ActiveRecord::Audit
        .where(action: :update, auditable_type: 'Item')
        .where("audited_changes REGEXP '.*price.*'")
        .order(:created_at)
        .group_by(&:auditable_id).each_pair do |item_id, audits|
      audit = audits.last
      change = audit.audited_changes['price']
      next unless change.compact.size == 2 and change.last <= change.first / 1000
      if audit.auditable.update_attributes(price: change.first)
        fixed_items << { item_id: item_id, price: change.first }
      end
    end
    puts fixed_items
  end
end
