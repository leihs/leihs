class MailTemplate < ActiveRecord::Base

  belongs_to :inventory_pool # NOTE when null, then is system-wide
  belongs_to :language

  validates_uniqueness_of :name, scope: [:inventory_pool_id, :language_id, :format]


  def self.liquid_variables_for_order(order, comment = nil, purpose = nil)
    {user: {name: order.target_user.name},
     inventory_pool: {name: order.inventory_pool.name,
                      description: order.inventory_pool.description},
     email_signature: Setting::EMAIL_SIGNATURE,
     order_lines: order.lines.map do |l|
       {quantity: l.quantity,
        model_name: l.model.name,
        start_date: l.start_date,
        end_date: l.end_date}
     end,
     histories: order.histories.select{|h| h.type_const == History::CHANGE}.map do |h|
       {text: h.text}
     end,
     comment: comment,
     purpose: purpose
    }.deep_stringify_keys
  end

  def self.liquid_variables_for_user(user, inventory_pool, visit_lines)
    {user: {name: user.name},
     inventory_pool: {name: inventory_pool.name,
                      description: inventory_pool.description},
     email_signature: Setting::EMAIL_SIGNATURE,
     contract_lines: visit_lines.map(&:contract_line).map do |l|
       {quantity: l.quantity,
        model_name: l.model.name,
        item_inventory_code: l.item.inventory_code,
        start_date: l.start_date,
        end_date: l.end_date}
     end,
     quantity: visit_lines.to_a.sum(&:quantity),
     due_date: visit_lines.first.date
    }.deep_stringify_keys
  end

  def self.get_template(scope, inventory_pool, name, language)
    mt = MailTemplate.find_by(inventory_pool_id: inventory_pool, name: name, language: language, format: "text")
    mt ||= MailTemplate.where(inventory_pool_id: inventory_pool, name: name, format: "text")

    if mt.blank?
      mt = MailTemplate.find_by(inventory_pool_id: nil, name: name, language: language, format: "text")
      mt ||= MailTemplate.where(inventory_pool_id: nil, name: name, format: "text")
    end

    if mt.blank?
      File.read(File.join(Rails.root, "app/views/mailer/#{scope}/", "#{name}.text.liquid"))
    else
      Array(mt).map(&:body).join('\n')
    end
  end

end
