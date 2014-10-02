module Search

  module Name
    extend ActiveSupport::Concern

    included do

      scope :search, lambda { |query|
        return all if query.blank?

        q = query.split.map {|s| "%#{s}%"}
        where(arel_table[:name].matches_all(q))
      }

    end

  end

end
