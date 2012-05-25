module Json
  module TemplateHelper

    def hash_for_template(template, with = nil)
      h = {
        id: template.id,
        name: template.name,
        type: template.class.to_s.underscore
      }
      
      h
    end

  end
end
