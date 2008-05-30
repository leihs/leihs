#
# This file is for Rails-1.1.6.
# From activesupport-1.4.1/lib/active_support/core_ext/module/aliasing.rb
#
class Module
  unless defined? alias_method_chain
    def alias_method_chain(target, feature)
      # Strip out punctuation on predicates or bang methods since
      # e.g. target?_without_feature is not a valid method name.
      aliased_target, punctuation = target.to_s.sub(/([?!=])$/, ''), $1
      yield(aliased_target, punctuation) if block_given?
      alias_method "#{aliased_target}_without_#{feature}#{punctuation}", target
      alias_method target, "#{aliased_target}_with_#{feature}#{punctuation}"
    end
  end
end
