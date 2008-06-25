class ActsAsGraphTest < Test::Unit::TestCase
  # This hack autoloads the models from the test/models/CLASSNAME.rb file
  def self.const_missing(const)
    # This idea is noted as being in "Very poor style" by Dave Thomas in Programming Ruby.
    # But, then, what does Dave Thomas know?

    filename = File.dirname(__FILE__) + "/models/#{const.to_s.tableize.singularize}"
    if File.file? filename + ".rb"
      # Load the file for the model that is being referenced.
      #puts "Loading #{const}"
      require filename
      return const_get(const)
    else
      super
    end
  end

private

  def create_node(klass, name)
    n = klass.new(:name => name.to_s)
    assert_nothing_raised { n.save }
    assert_equal klass, n.class
    assert n
    n
  end

  def instantiate_nodes(klass, *nodes)
    nodes.each do |n|
      instance_variable_set("@#{n.to_s}".to_sym, create_node(klass, n))
    end
  end
end