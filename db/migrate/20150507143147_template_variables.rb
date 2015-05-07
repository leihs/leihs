class TemplateVariables < ActiveRecord::Migration
  def change

    execute %Q(UPDATE mail_templates SET body = REPLACE(body, 'order_lines', 'reservations');)
    execute %Q(UPDATE mail_templates SET body = REPLACE(body, 'contract_lines', 'reservations');)

  end
end
