module Procurement
  class Setting < ActiveRecord::Base

    KEYS = %w(contact_url)

    validates_presence_of :key, :value
    validates_uniqueness_of :key

    def self.all_as_hash
      h = {}

      KEYS.each do |k|
        h[k] = nil
      end

      all.order(key: :asc).each do |s|
        h[s.key] = s.value
      end

      h
    end

  end
end
