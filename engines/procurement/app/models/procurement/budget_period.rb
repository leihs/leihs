module Procurement
  class BudgetPeriod < ActiveRecord::Base

    has_many :requests
    has_many :budget_limits, dependent: :delete_all

    validates_presence_of :name, :inspection_start_date, :end_date
    validates_uniqueness_of :name, :inspection_start_date, :end_date
    validate do
      if end_date < inspection_start_date
        errors.add(:end_date,
                   _('must be greater or equal to the inspection start date'))
      end
    end

    ####################################################

    scope :future, -> { where('end_date > ?', Time.zone.today) }

    ####################################################

    def to_s
      name
    end

    def in_requesting_phase?
      Time.zone.today < inspection_start_date
    end

    def in_inspection_phase?
      inspection_start_date <= Time.zone.today and Time.zone.today <= end_date
    end

    def previous
      self.class.order(end_date: :desc).find_by('end_date < ?', end_date)
    end

    def current?
      Time.zone.today <= end_date and \
        (previous.nil? or Time.zone.today > previous.end_date)
    end

    def past?
      end_date < Time.zone.today
    end

    class << self

      def current
        order(end_date: :asc).find_by('end_date >= CURDATE()')
      end

    end

  end
end
