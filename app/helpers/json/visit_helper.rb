module Json
  module VisitHelper

    def hash_for_visit(visit, with = nil)
      h = {
        type: "visit",
        action: visit.action,
        date: visit.date
      }
      
      if with ||= nil
        [:quantity, :is_overdue].each do |k|
          h[k] = visit.send(k) if with[k]
        end
      
        if with[:lines]
          lines = visit.lines.sort_by(&:created_at)
          h[:lines] = hash_for lines, with[:lines]
        end
        
        if with[:user]
          h[:user] = hash_for visit.user, with[:user] 
        end
      end
      
      h
    end

  end
end
