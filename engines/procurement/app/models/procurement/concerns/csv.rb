module Procurement
  module Csv
    extend ActiveSupport::Concern

    included do
      def self.csv_export(requests, current_user)
        Export.csv_string *header_and_objects(requests, current_user)
      end

      def self.excel_export(requests, current_user)
        Export.excel_string *header_and_objects(requests, current_user),
                            worksheet_name: _('Requests')
      end

      def self.header_and_objects(requests, current_user)
        objects = []
        requests.each do |request|
          objects << request.csv_columns(current_user)
        end
        header = objects.flat_map(&:keys).uniq
        [header, objects]
      end

      # rubocop:disable Metrics/MethodLength
      def csv_columns(current_user)
        show_all = (not budget_period.in_requesting_phase?) \
                      or category.inspectable_or_readable_by?(current_user)
        { _('Budget period') => budget_period.to_s,
          _('Main category') => category.main_category.name,
          _('Subcategory') => category.name,
          _('Requester') => user,
          _('Department') => organization.parent.name,
          _('Organisation') => organization.name,
          _('Article or Project') => article_name,
          _('Article nr. or Producer nr.') => article_number,
          _('Supplier') => supplier_name,
          _('Requested quantity') => requested_quantity,
          _('Approved quantity') => show_all ? approved_quantity : nil,
          _('Order quantity') => show_all ? order_quantity : nil,
          format('%s %s', _('Price'), _('incl. VAT')) => price,
          format('%s %s', _('Total'), _('incl. VAT')) => total_price(current_user),
          _('State') => _(state(current_user).to_s.humanize),
          _('Priority') => priority,
          _("Inspector's priority") => inspector_priority,
          format('%s / %s', _('Replacement'), _('New')) => \
                                  replacement ? _('Replacement') : _('New'),
          _('Receiver') => receiver,
          _('Point of Delivery') => location_name,
          _('Motivation') => motivation,
          _('Inspection comment') => show_all ? inspection_comment : nil
        }
      end
      # rubocop:enable Metrics/MethodLength

    end

  end
end
