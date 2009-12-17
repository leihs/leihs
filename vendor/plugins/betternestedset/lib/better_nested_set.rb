module SymetrieCom
  module Acts #:nodoc:
    module NestedSet #:nodoc:
      def self.included(base)
        base.extend(ClassMethods)              
      end
      # This module provides an enhanced acts_as_nested_set mixin for ActiveRecord.
      # Please see the README for background information, examples, and tips on usage.
      module ClassMethods
        # Configuration options are:
        # * +parent_column+ - Column name for the parent/child foreign key (default: +parent_id+).
        # * +left_column+ - Column name for the left index (default: +lft+). 
        # * +right_column+ - Column name for the right index (default: +rgt+). NOTE: 
        #   Don't use +left+ and +right+, since these are reserved database words.
        # * +scope+ - Restricts what is to be considered a tree. Given a symbol, it'll attach "_id" 
        #   (if it isn't there already) and use that as the foreign key restriction. It's also possible 
        #   to give it an entire string that is interpolated if you need a tighter scope than just a foreign key.
        #   Example: <tt>acts_as_nested_set :scope => 'tree_id = #{tree_id} AND completed = 0'</tt>
        # * +text_column+ - Column name for the title field (optional). Used as default in the 
        #   {your-class}_options_for_select helper method. If empty, will use the first string field 
        #   of your model class.
        def acts_as_nested_set(options = {})          
          
          options[:scope] = "#{options[:scope]}_id".intern if options[:scope].is_a?(Symbol) && options[:scope].to_s !~ /_id$/
          
          write_inheritable_attribute(:acts_as_nested_set_options,
             { :parent_column  => (options[:parent_column] || 'parent_id'),
               :left_column    => (options[:left_column]   || 'lft'),
               :right_column   => (options[:right_column]  || 'rgt'),
               :scope          => (options[:scope] || '1 = 1'),
               :text_column    => (options[:text_column] || columns.collect{|c| (c.type == :string) ? c.name : nil }.compact.first),
               :class          => self # for single-table inheritance
              } )
          
          class_inheritable_reader :acts_as_nested_set_options
          
          if acts_as_nested_set_options[:scope].is_a?(Symbol)
            scope_condition_method = %(
              def scope_condition
                if #{acts_as_nested_set_options[:scope].to_s}.nil?
                  "#{acts_as_nested_set_options[:scope].to_s} IS NULL"
                else
                  "#{acts_as_nested_set_options[:scope].to_s} = \#{#{acts_as_nested_set_options[:scope].to_s}}"
                end
              end
            )
          else
            scope_condition_method = "def scope_condition() \"#{acts_as_nested_set_options[:scope]}\" end"
          end
          
          # no bulk assignment
          attr_protected  acts_as_nested_set_options[:left_column].intern,
                          acts_as_nested_set_options[:right_column].intern,
                          acts_as_nested_set_options[:parent_column].intern
          # no assignment to structure fields
          module_eval <<-"end_eval", __FILE__, __LINE__
            def #{acts_as_nested_set_options[:left_column]}=(x)
              raise ActiveRecord::ActiveRecordError, "Unauthorized assignment to #{acts_as_nested_set_options[:left_column]}: it's an internal field handled by acts_as_nested_set code, use move_to_* methods instead."
            end
            def #{acts_as_nested_set_options[:right_column]}=(x)
              raise ActiveRecord::ActiveRecordError, "Unauthorized assignment to #{acts_as_nested_set_options[:right_column]}: it's an internal field handled by acts_as_nested_set code, use move_to_* methods instead."
            end
            def #{acts_as_nested_set_options[:parent_column]}=(x)
              raise ActiveRecord::ActiveRecordError, "Unauthorized assignment to #{acts_as_nested_set_options[:parent_column]}: it's an internal field handled by acts_as_nested_set code, use move_to_* methods instead."
            end
            #{scope_condition_method}
          end_eval
          
          
          include SymetrieCom::Acts::NestedSet::InstanceMethods
          extend SymetrieCom::Acts::NestedSet::ClassMethods
          
          # adds the helper for the class
#          ActionView::Base.send(:define_method, "#{Inflector.underscore(self.class)}_options_for_select") { special=nil
#              "#{acts_as_nested_set_options[:text_column]} || "#{self.class} id #{id}"
#            }
          
        end
        
        
        # Returns the single root for the class (or just the first root, if there are several).
        # Deprecation note: the original acts_as_nested_set allowed roots to have parent_id = 0,
        # so we currently do the same. This silliness will not be tolerated in future versions, however.
        def root
          acts_as_nested_set_options[:class].find(:first, :conditions => "(#{acts_as_nested_set_options[:parent_column]} IS NULL OR #{acts_as_nested_set_options[:parent_column]} = 0)")
        end
        
        # Returns the roots and/or virtual roots of all trees. See the explanation of virtual roots in the README.
        def roots
          acts_as_nested_set_options[:class].find(:all, :conditions => "(#{acts_as_nested_set_options[:parent_column]} IS NULL OR #{acts_as_nested_set_options[:parent_column]} = 0)", :order => "#{acts_as_nested_set_options[:left_column]}")
        end
        
        # Checks the left/right indexes of all records, 
        # returning the number of records checked. Throws ActiveRecord::ActiveRecordError if it finds a problem.
        def check_all
          total = 0
          transaction do
            # if there are virtual roots, only call check_full_tree on the first, because it will check other virtual roots in that tree.
            total = roots.inject(0) {|sum, r| sum + (r[r.left_col_name] == 1 ? r.check_full_tree : 0 )}
            raise ActiveRecord::ActiveRecordError, "Scope problems or nodes without a valid root" unless acts_as_nested_set_options[:class].count == total
          end
          return total
        end
        
        # Re-calculate the left/right values of all nodes. Can be used to convert ordinary trees into nested sets.
        def renumber_all
          scopes = []
          # only call it once for each scope_condition (if the scope conditions are messed up, this will obviously cause problems)
          roots.each do |r|
            r.renumber_full_tree unless scopes.include?(r.scope_condition)
            scopes << r.scope_condition
          end
        end
        
        # Returns an SQL fragment that matches _items_ *and* all of their descendants, for use in a WHERE clause.
        # You can pass it a single object, a single ID, or an array of objects and/or IDs.
        #   # if a.lft = 2, a.rgt = 7, b.lft = 12 and b.rgt = 13
        #   Set.sql_for([a,b]) # returns "((lft BETWEEN 2 AND 7) OR (lft BETWEEN 12 AND 13))"
        # Returns "1 != 1" if passed no items. If you need to exclude items, just use "NOT (#{sql_for(items)})".
        # Note that if you have multiple trees, it is up to you to apply your scope condition.
        def sql_for(items)
          items = [items] unless items.is_a?(Array)
          # get objects for IDs
          items.collect! {|s| s.is_a?(acts_as_nested_set_options[:class]) ? s : acts_as_nested_set_options[:class].find(s)}.uniq
          items.reject! {|e| e.new_record?} # exclude unsaved items, since they don't have left/right values yet
          
          return "1 != 1" if items.empty? # PostgreSQL didn't like '0', and SQLite3 didn't like 'FALSE'
          items.map! {|e| "(#{acts_as_nested_set_options[:left_column]} BETWEEN #{e[acts_as_nested_set_options[:left_column]]} AND #{e[acts_as_nested_set_options[:right_column]]})" }
          "(#{items.join(' OR ')})"
        end
        
      end

      # This module provides instance methods for an enhanced acts_as_nested_set mixin. Please see the README for background information, examples, and tips on usage.
      module InstanceMethods
        # convenience methods to make the code more readable
        def left_col_name()#:nodoc:
          acts_as_nested_set_options[:left_column]
        end
        def right_col_name()#:nodoc:
          acts_as_nested_set_options[:right_column]
        end
        def parent_col_name()#:nodoc:
          acts_as_nested_set_options[:parent_column]
        end
        alias parent_column parent_col_name#:nodoc: Deprecated
        def base_set_class()#:nodoc:
          acts_as_nested_set_options[:class] # for single-table inheritance
        end
        
        # On creation, automatically add the new node to the right of all existing nodes in this tree.
        def before_create # already protected by a transaction
          maxright = base_set_class.maximum(right_col_name, :conditions => scope_condition) || 0
          self[left_col_name] = maxright+1
          self[right_col_name] = maxright+2
        end
        
        # On destruction, delete all children and shift the lft/rgt values back to the left so the counts still work.
        def before_destroy # already protected by a transaction
          return if self[right_col_name].nil? || self[left_col_name].nil?
          self.reload # in case a concurrent move has altered the indexes
          dif = self[right_col_name] - self[left_col_name] + 1
          base_set_class.delete_all( "#{scope_condition} AND (#{left_col_name} BETWEEN #{self[left_col_name]} AND #{self[right_col_name]})" )
          base_set_class.update_all("#{left_col_name} = CASE \
                                      WHEN #{left_col_name} > #{self[right_col_name]} THEN (#{left_col_name} - #{dif}) \
                                      ELSE #{left_col_name} END, \
                                 #{right_col_name} = CASE \
                                      WHEN #{right_col_name} > #{self[right_col_name]} THEN (#{right_col_name} - #{dif} ) \
                                      ELSE #{right_col_name} END",
                                 scope_condition)
        end
        
        # By default, records are compared and sorted using the left column.
        def <=>(x)
          self[left_col_name] <=> x[left_col_name]
        end
        
        # Deprecated. Returns true if this is a root node.
        def root?
          parent_id = self[parent_col_name]
          (parent_id == 0 || parent_id.nil?) && self[right_col_name] && self[left_col_name] && (self[right_col_name] > self[left_col_name])
        end
        
        # Deprecated. Returns true if this is a child node
        def child?                          
          parent_id = self[parent_col_name]
          !(parent_id == 0 || parent_id.nil?) && (self[left_col_name] > 1) && (self[right_col_name] > self[left_col_name])
        end
        
        # Deprecated. Returns true if we have no idea what this is
        def unknown?
          !root? && !child?
        end
        
        # Returns this record's root ancestor.
        def root
          # the BETWEEN clause is needed to ensure we get the right virtual root, if using those
          base_set_class.find(:first, :conditions => "#{scope_condition} \
            AND (#{parent_col_name} IS NULL OR #{parent_col_name} = 0) AND (#{self[left_col_name]} BETWEEN #{left_col_name} AND #{right_col_name})")
        end
        
        # Returns the root or virtual roots of this record's tree (a tree cannot have more than one real root). See the explanation of virtual roots in the README.
        def roots
          base_set_class.find(:all, :conditions => "#{scope_condition} AND (#{parent_col_name} IS NULL OR #{parent_col_name} = 0)", :order => "#{left_col_name}")
        end
        
        # Returns this record's parent.
        def parent
          base_set_class.find(self[parent_col_name]) if self[parent_col_name]
        end
        
        # Returns an array of all parents, starting with the root.
        def ancestors
          self_and_ancestors - [self]
        end
        
        # Returns an array of all parents plus self, starting with the root.
        def self_and_ancestors
          base_set_class.find(:all, :conditions => "#{scope_condition} AND (#{self[left_col_name]} BETWEEN #{left_col_name} AND #{right_col_name})", :order => left_col_name )
        end
        
        # Returns all the children of this node's parent, except self.
        def siblings
          self_and_siblings - [self]
        end
        
        # Returns all the children of this node's parent, including self.
        def self_and_siblings
          if self[parent_col_name].nil? || self[parent_col_name].zero?
            [self]
          else
            base_set_class.find(:all, :conditions => "#{scope_condition} AND #{parent_col_name} = #{self[parent_col_name]}", :order => left_col_name)
          end
        end
        
        # Returns the level of this object in the tree, root level being 0.
        def level
          return 0 if self[parent_col_name].nil?
          base_set_class.count(:conditions => "#{scope_condition} AND (#{self[left_col_name]} BETWEEN #{left_col_name} AND #{right_col_name})") - 1
        end
        
        # Returns the number of nested children of this object.
        def all_children_count
          return (self[right_col_name] - self[left_col_name] - 1)/2
        end
        
        # Returns itself and all nested children.
        # Pass :exclude => item, or id, or [items or id] to exclude one or more items *and* all of their descendants.
        def full_set(special=nil)
          if special && special[:exclude]
            exclude_str = " AND NOT (#{base_set_class.sql_for(special[:exclude])}) "
          elsif new_record? || self[right_col_name] - self[left_col_name] == 1
            return [self]
          end
          base_set_class.find(:all, :conditions => "#{scope_condition} #{exclude_str} AND (#{left_col_name} BETWEEN #{self[left_col_name]} AND #{self[right_col_name]})", :order => left_col_name)
        end
        
        # Returns all children and nested children.
        # Pass :exclude => item, or id, or [items or id] to exclude one or more items *and* all of their descendants.
        def all_children(special=nil)
          full_set(special) - [self]
        end
        
        # Returns this record's immediate children.
        def children
          base_set_class.find(:all, :conditions => "#{scope_condition} AND #{parent_col_name} = #{self.id}", :order => left_col_name)
        end
        
        # Deprecated
        alias direct_children children
        
        # Returns this record's terminal children (nodes without children).
        def leaves
          base_set_class.find(:all, :conditions => "#{scope_condition} AND (#{left_col_name} BETWEEN #{self[left_col_name]} AND #{self[right_col_name]}) AND #{left_col_name} + 1 = #{right_col_name}", :order => left_col_name)
        end
        
        # Returns the count of this record's terminal children (nodes without children).
        def leaves_count
          base_set_class.count(:conditions => "#{scope_condition} AND (#{left_col_name} BETWEEN #{self[left_col_name]} AND #{self[right_col_name]}) AND #{left_col_name} + 1 = #{right_col_name}")
        end
        
        # Checks the left/right indexes of one node and all descendants. 
        # Throws ActiveRecord::ActiveRecordError if it finds a problem.
        def check_subtree
          transaction do
            self.reload
            check # this method is implemented via #check, so that we don't generate lots of unnecessary nested transactions
          end
        end
        
        # Checks the left/right indexes of the entire tree that this node belongs to, 
        # returning the number of records checked. Throws ActiveRecord::ActiveRecordError if it finds a problem.
        # This method is needed because check_subtree alone cannot find gaps between virtual roots, orphaned nodes or endless loops.
        def check_full_tree
          total_nodes = 0
          transaction do
            # virtual roots make this method more complex than it otherwise would be
            n = 1
            roots.each do |r| 
              raise ActiveRecord::ActiveRecordError, "Gaps between roots in the tree containing record ##{r.id}" if r[left_col_name] != n
              r.check_subtree
              n = r[right_col_name] + 1
            end
            total_nodes = roots.inject(0) {|sum, r| sum + r.all_children_count + 1 }
            unless base_set_class.count(:conditions => "#{scope_condition}") == total_nodes
              raise ActiveRecord::ActiveRecordError, "Orphaned nodes or endless loops in the tree containing record ##{self.id}"
            end
          end
          return total_nodes
        end
        
        # Re-calculate the left/right values of all nodes in this record's tree. Can be used to convert an ordinary tree into a nested set.
        def renumber_full_tree
          indexes = []
          n = 1
          transaction do
            for r in roots # because we may have virtual roots
              n = r.calc_numbers(n, indexes)
            end
            for i in indexes
              base_set_class.update_all("#{left_col_name} = #{i[:lft]}, #{right_col_name} = #{i[:rgt]}", "#{self.class.primary_key} = #{i[:id]}")
            end
          end
          ## reload?
        end
        
        # Deprecated. Adds a child to this object in the tree.  If this object hasn't been initialized,
        # it gets set up as a root node.
        #
        # This method exists only for compatibility and will be removed in future versions.
        def add_child(child)
          transaction do
            self.reload; child.reload # for compatibility with old version
            # the old version allows records with nil values for lft and rgt
            unless self[left_col_name] && self[right_col_name]
              if child[left_col_name] || child[right_col_name]
                raise ActiveRecord::ActiveRecordError, "If parent lft or rgt are nil, you can't add a child with non-nil lft or rgt"
              end
              base_set_class.update_all("#{left_col_name} = CASE \
                                          WHEN id = #{self.id} \
                                            THEN 1 \
                                          WHEN id = #{child.id} \
                                            THEN 3 \
                                          ELSE #{left_col_name} END, \
                                     #{right_col_name} = CASE \
                                          WHEN id = #{self.id} \
                                            THEN 2 \
                                          WHEN id = #{child.id} \
                                            THEN 4 \
                                         ELSE #{right_col_name} END",
                                      scope_condition)
              self.reload; child.reload
            end
            unless child[left_col_name] && child[right_col_name]
              maxright = base_set_class.maximum(right_col_name, :conditions => scope_condition) || 0
              base_set_class.update_all("#{left_col_name} = CASE \
                                          WHEN id = #{child.id} \
                                            THEN #{maxright + 1} \
                                          ELSE #{left_col_name} END, \
                                      #{right_col_name} = CASE \
                                          WHEN id = #{child.id} \
                                            THEN #{maxright + 2} \
                                          ELSE #{right_col_name} END",
                                      scope_condition)
              child.reload
            end
            
            child.move_to_child_of(self)
            # self.reload ## even though move_to calls target.reload, at least one object in the tests was not reloading (near the end of test_common_usage)
          end
        # self.reload
        # child.reload
        #
        # if child.root?
        #   raise ActiveRecord::ActiveRecordError, "Adding sub-tree isn\'t currently supported"
        # else
        #   if ( (self[left_col_name] == nil) || (self[right_col_name] == nil) )
        #     # Looks like we're now the root node!  Woo
        #     self[left_col_name] = 1
        #     self[right_col_name] = 4
        #     
        #     # What do to do about validation?
        #     return nil unless self.save
        #     
        #     child[parent_col_name] = self.id
        #     child[left_col_name] = 2
        #     child[right_col_name]= 3
        #     return child.save
        #   else
        #     # OK, we need to add and shift everything else to the right
        #     child[parent_col_name] = self.id
        #     right_bound = self[right_col_name]
        #     child[left_col_name] = right_bound
        #     child[right_col_name] = right_bound + 1
        #     self[right_col_name] += 2
        #     self.class.transaction {
        #       self.class.update_all( "#{left_col_name} = (#{left_col_name} + 2)",  "#{scope_condition} AND #{left_col_name} >= #{right_bound}" )
        #       self.class.update_all( "#{right_col_name} = (#{right_col_name} + 2)",  "#{scope_condition} AND #{right_col_name} >= #{right_bound}" )
        #       self.save
        #       child.save
        #     }
        #   end
        # end
        end
        
        # Move this node to the left of _target_ (you can pass an object or just an id).
        # Unsaved changes in either object will be lost. Raises ActiveRecord::ActiveRecordError if it encounters a problem.
        def move_to_left_of(target)
          self.move_to target, :left
        end
        
        # Move this node to the right of _target_ (you can pass an object or just an id).
        # Unsaved changes in either object will be lost. Raises ActiveRecord::ActiveRecordError if it encounters a problem.
        def move_to_right_of(target)
          self.move_to target, :right
        end
        
        # Make this node a child of _target_ (you can pass an object or just an id).
        # Unsaved changes in either object will be lost. Raises ActiveRecord::ActiveRecordError if it encounters a problem.
        def move_to_child_of(target)
          self.move_to target, :child
        end
        
        protected
        def move_to(target, position) #:nodoc:
          raise ActiveRecord::ActiveRecordError, "You cannot move a new node" if new_record?
          raise ActiveRecord::ActiveRecordError, "You cannot move a node if left or right is nil" unless self[left_col_name] && self[right_col_name]
          
          transaction do
            self.reload # the lft/rgt values could be stale (target is reloaded below)
            if target.is_a?(base_set_class)
              target.reload # could be stale
            else
              target = base_set_class.find(target) # load object if we were given an ID
            end
            
            if (target[left_col_name] >= self[left_col_name]) && (target[right_col_name] <= self[right_col_name])
              raise ActiveRecord::ActiveRecordError, "Impossible move, target node cannot be inside moved tree."
            end
            
            # prevent moves between different trees
            if target.scope_condition != scope_condition
              raise ActiveRecord::ActiveRecordError, "Scope conditions do not match. Is the target in the same tree?"
            end
            
            # the move: we just need to define two adjoining segments of the left/right index and swap their positions
            bound = case position
              when :child then target[right_col_name]
              when :left  then target[left_col_name]
              when :right then target[right_col_name] + 1
              else raise ActiveRecord::ActiveRecordError, "Position should be :child, :left or :right ('#{position}' received)."
            end
            
            if bound > self[right_col_name]
              bound = bound - 1
              other_bound = self[right_col_name] + 1
            else
              other_bound = self[left_col_name] - 1
            end
            
            return if bound == self[right_col_name] || bound == self[left_col_name] # there would be no change, and other_bound is now wrong anyway
            
            # we have defined the boundaries of two non-overlapping intervals, 
            # so sorting puts both the intervals and their boundaries in order
            a, b, c, d = [self[left_col_name], self[right_col_name], bound, other_bound].sort
            
            # change nil to NULL for new parent
            if position == :child
              new_parent = target.id
            else
              new_parent = target[parent_col_name].nil? ? 'NULL' : target[parent_col_name]
            end
            
            base_set_class.update_all("\
              #{left_col_name} = CASE \
                WHEN #{left_col_name} BETWEEN #{a} AND #{b} THEN #{left_col_name} + #{d - b} \
                WHEN #{left_col_name} BETWEEN #{c} AND #{d} THEN #{left_col_name} + #{a - c} \
                ELSE #{left_col_name} END, \
              #{right_col_name} = CASE \
                WHEN #{right_col_name} BETWEEN #{a} AND #{b} THEN #{right_col_name} + #{d - b} \
                WHEN #{right_col_name} BETWEEN #{c} AND #{d} THEN #{right_col_name} + #{a - c} \
                ELSE #{right_col_name} END, \
              #{parent_col_name} = CASE \
                WHEN #{self.class.primary_key} = #{self.id} THEN #{new_parent} \
                ELSE #{parent_col_name} END",
              scope_condition)
            self.reload
            target.reload
          end
        end
        
        def check #:nodoc:
          # performance improvements (3X or more for tables with lots of columns) by using :select to load just id, lft and rgt
          ## i don't use the scope condition here, because it shouldn't be needed
          my_children = base_set_class.find(:all, :conditions => "#{parent_col_name} = #{self.id}",
            :order => left_col_name, :select => "#{self.class.primary_key}, #{left_col_name}, #{right_col_name}")
          
          if my_children.empty?
            unless self[left_col_name] && self[right_col_name]
              raise ActiveRecord::ActiveRecordError, "#{self.class.name}##{self.id}.#{right_col_name} or #{left_col_name} is blank"
            end
            unless self[right_col_name] - self[left_col_name] == 1
              raise ActiveRecord::ActiveRecordError, "#{self.class.name}##{self.id}.#{right_col_name} should be 1 greater than #{left_col_name}"
            end
          else
            n = self[left_col_name]
            for c in (my_children) # the children come back ordered by lft
              unless c[left_col_name] && c[right_col_name]
                raise ActiveRecord::ActiveRecordError, "#{self.class.name}##{c.id}.#{right_col_name} or #{left_col_name} is blank"
              end
              unless c[left_col_name] == n + 1
                raise ActiveRecord::ActiveRecordError, "#{self.class.name}##{c.id}.#{left_col_name} should be 1 greater than #{n}"
              end
              c.check
              n = c[right_col_name]
            end
            unless self[right_col_name] == n + 1
              raise ActiveRecord::ActiveRecordError, "#{self.class.name}##{self.id}.#{right_col_name} should be 1 greater than #{n}"
            end
          end
        end
        
        # used by the renumbering methods
        def calc_numbers(n, indexes) #:nodoc:
          my_lft = n
          # performance improvements (3X or more for tables with lots of columns) by using :select to load just id, lft and rgt
          ## i don't use the scope condition here, because it shouldn't be needed
          my_children = base_set_class.find(:all, :conditions => "#{parent_col_name} = #{self.id}",
            :order => left_col_name, :select => "#{self.class.primary_key}, #{left_col_name}, #{right_col_name}")
          if my_children.empty?
            my_rgt = (n += 1)
          else
            for c in (my_children)
              n = c.calc_numbers(n + 1, indexes)
            end
            my_rgt = (n += 1)
          end
          indexes << {:id => self.id, :lft => my_lft, :rgt => my_rgt} unless self[left_col_name] == my_lft && self[right_col_name] == my_rgt
          return n
        end
        
        
        
        # The following code is my crude method of making things concurrency-safe.
        # Basically, we need to ensure that whenever a record is saved, the lft/rgt
        # values are _not_ written to the database, because if any changes to the tree
        # structure occurrred since the object was loaded, the lft/rgt values could 
        # be out of date and corrupt the indexes. 
        # I hope that someone with a little more ruby-foo can look at this and come
        # up with a more elegant solution.
        private
          # override ActiveRecord to prevent lft/rgt values from being saved (can corrupt indexes under concurrent usage)
          def update #:nodoc:
            connection.update(
              "UPDATE #{self.class.table_name} " +
              "SET #{quoted_comma_pair_list(connection, special_attributes_with_quotes(false))} " +
              "WHERE #{self.class.primary_key} = #{quote_value(id)}",
              "#{self.class.name} Update"
            )
          end

          # exclude the lft/rgt columns from update statements
          def special_attributes_with_quotes(include_primary_key = true) #:nodoc:
            attributes.inject({}) do |quoted, (name, value)|
              if column = column_for_attribute(name)
                quoted[name] = quote_value(value, column) unless (!include_primary_key && column.primary) || [acts_as_nested_set_options[:left_column], acts_as_nested_set_options[:right_column]].include?(column.name)
              end
              quoted
            end
          end

          # i couldn't figure out how to call attributes_with_quotes without cutting and pasting this private method in.  :(
          # Quote strings appropriately for SQL statements.
          def quote_value(value, column = nil) #:nodoc:
            self.class.connection.quote(value, column)
          end

      end
    end
  end
end


