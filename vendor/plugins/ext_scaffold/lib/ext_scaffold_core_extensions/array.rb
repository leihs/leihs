module ExtScaffoldCoreExtensions
  module Array

    # return Ext compatible JSON form of an Array, i.e.:
    #  {"results": n, 
    #   "posts": [ {"id": 1, "title": "First Post",
    #               "body": "This is my first post.",
    #               "published": true, ... },
    #               ...
    #            ]
    #  }
    def to_ext_json(options = {})
      if given_class = options.delete(:class)
        element_class = (given_class.is_a?(Class) ? given_class : given_class.to_s.classify.constantize)
      else
        element_class = first.class
      end
      element_count = options.delete(:count) || self.length

      { :results => element_count, element_class.to_s.underscore.pluralize => self }.to_json(options)
    end

  end
end
