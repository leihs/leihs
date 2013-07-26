class BreadCrumbs

  def add(link, label)
    @crumbs << [link, label]
  end

  def initialize(params)
    @crumbs = []
    if params["_bc"]
      for crumb in params["_bc"].values
        add crumb[0], crumb[1]
      end
    end
  end

  def get
    @crumbs
  end

  def path_for(path, name)
    uri = URI(path)                                                                                    
    query_hash = Rack::Utils.parse_query(uri.query)                                                   
    query_hash.merge!(to_params([path, CGI::escape(name)]))
    uri.query = query_hash.to_param

    path_including_breadcrumb = URI(uri.to_s)
    query_hash = Rack::Utils.parse_query(uri.query)                                                   
    query_hash.merge!(to_params([path_including_breadcrumb, CGI::escape(name)]))
    uri.query = query_hash.to_param

    uri.to_s
  end

  def to_params(addition)
    crumbs = @crumbs.dup
    crumbs.push addition if addition
    h = {"_bc" => {}}
    crumbs.each_with_index do |crumb, i|
      h["_bc"][i] = crumb
    end
    h
  end

end