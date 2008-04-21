module Backend::AcknowledgeHelper

  def today_or_yesterday_date(past_date)
    current_date_00 = Time.now.at_midnight
    past_date_00 = past_date.at_midnight

    d = ""
    if past_date_00.eql? current_date_00
      d += _("Today")
    elsif past_date_00.eql?(current_date_00 - 1.day)
      d += _("Yesterday")
    else
      d += past_date.strftime("%d.%m.%Y")
    end
    d += " " + past_date.strftime("%H:%M")
  end

end
