module Procurement
  module ApplicationHelper

    # override money-rails helper
    def money_without_cents_and_with_symbol(value, with_symbol = true)
      value = Money.new(value) unless value.respond_to? :currency
      number_to_currency(value.to_i,
                         unit: with_symbol ? "#{value.currency} " : '',
                         separator: '.',
                         delimiter: "'",
                         precision: 0)
    end

    def label_class(key)
      case key
      when :new
          'label-info'
      when :in_inspection
          'label-primary'
      when :denied
          'label-danger'
      when :partially_approved
          'label-warning'
      when :approved
          'label-success'
      else
          raise
      end
    end

    def state_label(request)
      state = request.state(current_user)
      [state, label_class(state)]
    end

    def header_color(budget_period)
      if budget_period.current?
        if budget_period.in_inspection_phase?
          'warning'
        else
          'success'
        end
      else
        'info'
      end
    end
  end
end
