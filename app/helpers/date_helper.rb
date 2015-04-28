module DateHelper

  def interval(start_date, end_date)
    interval = (end_date - start_date).to_i.abs + 1
    pluralize(interval, _('Day'), _('Days'))
  end

end