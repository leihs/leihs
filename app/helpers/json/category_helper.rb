module Json
  module CategoryHelper

    def hash_for_category(category, with = nil)
      h = {
          type: 'category',
          id: category.id
      }

      if with ||= nil
        [:name].each do |k|
          h[k] = category.send(k) if with[k]
        end

        if with[:children]
          h[:children] = hash_for(category.children.order("name asc"), with)
        end

        if with[:is_used]
          h[:is_used] = !(category.models.empty? and category.children.empty?)
        end

      end

      h
    end

  end
end
