class BreadCrumbs

  def initialize(params)
    @crumbs = []
    if params["_bc"]
      for crumb in params["_bc"]
        add crumb["label"], crumb["link"], crumb.symbolize_keys
      end
    end
  end

  def add(label, link, *options)
    bc = {:label => label, :link => link}
    for option in options 
      bc.merge! option
    end
    @crumbs << bc 
  end

  def to_params
    {:_bc => @crumbs}
  end

  def get
    @crumbs
  end

end
