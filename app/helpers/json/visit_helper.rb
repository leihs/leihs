module Json
  module VisitHelper

    def hash_for_visit(visit, with = nil)
      h = {
        type: "visit",
        id: visit.id,
        action: visit.action,
        date: visit.date
      }

      if with ||= nil
        [:quantity, :is_overdue].each do |k|
          h[k] = visit.send(k) if with[k]
        end
      
        if with[:lines]
          lines = visit.lines.sort_by {|x| x.model.to_s }
          h[:lines] = hash_for lines, with[:lines]
        end
        
        if with[:user]
          h[:user] = hash_for visit.user, with[:user] 
        end

        if with[:latest_remind]
          latest_remind = visit.user.reminders.last
          h[:latest_remind] = latest_remind.created_at.to_s if latest_remind and latest_remind.created_at > visit.date
        end
      end
      
      h
    end

  end
end
