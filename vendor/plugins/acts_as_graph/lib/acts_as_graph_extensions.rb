module TammerSaleh #:nodoc:
  module Acts #:nodoc:
    module Graph #:nodoc
      module Extensions #:nodoc:
        # The Recursive class implements a Depth First Search on the collection.
        # All Enumerable methods (+each+, +map+, +find+, etc.) are defined on objects of 
        # this class.  In addition, it supports <tt>to_a()</tt>, and passes all unknown methods 
        # to the array returned from that call.
        class Recursive
          #--
          # Note: Should consider making this a proxy obj like AssociationProxy
          #++
          include Enumerable
          
          def initialize(collection, reflection) #:nodoc:
            @collection = collection
            @reflection = reflection
          end
          
          # call-seq:
          #     each { |node| ... } -> nil
          #
          # Calls the given block once for each node in the DFS, 
          # passing that node as a parameter.
          def each(seen = [], &block) 
            @collection.each do |node|
              if not seen.include?(node)
                seen << node  # mark the node as seen so we don't visit it twice
                node_collection = node.send(@reflection.name)
                node_collection.recursive.each(seen, &block)
                block.call(node)
              end
            end
          end

          # Returns all nodes in the current collection 
          # and all sub-collections (collected recursively).
          def to_a() # :doc:
            self.inject([]) { |ary,x| ary << x }
          end
          
          # All other methods on this object are passed on to the array returned by to_a()
          # This allows you to use the usual array accessors like [] and -
          def method_missing(message, *args)
            # This is my hack to make recursive act like an array.
            # puts "method_missing(#{message}, #{args.map(&:class).join(", ")})"
            self.to_a.send(message, *args)
          end
        end

        module HABTM
          #--
          # remember that @reflection.name is set to :children, :parents or :neighbors
          # @owner is set to node that owns collection
          #++
          
          # Returns an instance of the Recursive class.  This allows you to work on all of the 
          # children or parents of the given node.  
          def recursive
            @recursive ||= TammerSaleh::Acts::Graph::Extensions::Recursive.new(self, @reflection)
          end

          # Insert a node into the collection.  Raises an exception if the insertion would create
          # a cycle.
          def <<(*nodes)
            nodes = flatten_deeper([nodes]) # flatten_deeper is defined in AssociationProxy.rb
            
            raise_on_nodes_include_owner(nodes)
            raise_on_node_added_twice(nodes)
            raise_on_node_breaks_DAC(nodes)
            
            super(nodes)
          end
          
          private
          
          def raise_on_nodes_include_owner(nodes)
            if nodes.include? @owner
              raise ArgumentError,
                    "Attempt to add node to own graph collection when " +
                    ":allow_cycles is set to false."
            end
          end
          
          def raise_on_node_added_twice(nodes)
            if node_in_array_twice(nodes) or nodes_already_in_current_collection(nodes)
              raise ArgumentError,
                    "Attempt to add a child node twice when " +
                    ":allow_cycles is set to false."
            end
          end
          
          def raise_on_node_breaks_DAC(nodes)
            if not adding_nodes_maintains_DAC?(nodes)
              raise ArgumentError,
                    "Adding #{nodes.size > 1 ? "nodes": "node"} " + 
                    "#{nodes.map(&:id)} to node #{@owner.id} " + 
                    "would create a cycle when " +
                    ":allow_cycles is set to false."
            end
          end
          
          def nodes_already_in_current_collection(nodes)
            # The intersection of the args and my immediate children 
            # should be empty
            return (not (nodes & self).empty?)
          end
          
          def node_in_array_twice(nodes)
            return (nodes.size < nodes.uniq.size)
          end
          
          def adding_nodes_maintains_DAC?(nodes)
            if @reflection.name == @owner.class.acts_as_graph_options[:child_collection]
              other_reflection_name = @owner.class.acts_as_graph_options[:parent_collection]
            else 
              other_reflection_name = @owner.class.acts_as_graph_options[:child_collection]
            end
            
            nodes.each do |new_node|
              return false if @owner.send(other_reflection_name).recursive.include? new_node
            end
            
            return true
          end
        end

      end
    end
  end
end