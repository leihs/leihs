module Procurement
  module Filter
    extend ActiveSupport::Concern

    included do
      def default_filters
        @filter = params[:filter] || begin
          r = session[:requests_filter] || {}
          r.delete('search') # NOTE reset on each request
          r
        end
        @filter['user_id'] ||= @user.id if @user
        @filter['budget_period_ids'] ||= [Procurement::BudgetPeriod.current.id]
        @filter['group_ids'] ||= begin
          r = Procurement::GroupInspector.where(user_id: current_user) \
            .pluck(:group_id)
          r = Procurement::Group.pluck(:id) if r.empty?
          r
        end
        @filter['priorities'] ||= ['high', 'normal']
        @filter['states'] ||= Procurement::Request::STATES

        @filter['sort_by'] = 'state' if @filter['sort_by'].blank?
        @filter['sort_dir'] = 'asc' if @filter['sort_dir'].blank?
      end

      def get_requests
        fallback_filters
        h = {}
        Procurement::BudgetPeriod.order(end_date: :desc) \
          .find(@filter['budget_period_ids']).each do |budget_period|

          k = { group_id: @filter['group_ids'], priority: @filter['priorities'] }
          k[:user_id] = @user if @user
          requests = budget_period.requests.search(@filter['search']).where(k)

          if @filter['organization_id']
            requests = requests.joins(:organization)
                           .where(['organization_id = :id OR ' \
                                 'procurement_organizations.parent_id = :id',
                                   { id: @filter['organization_id'] }])
          end
          requests = requests.select do |r|
            @filter['states'].map(&:to_sym).include? r.state(current_user)
          end

          h[budget_period] = sort_requests(requests,
                                           @filter['sort_by'], @filter['sort_dir'])
        end
        h
      end

      private

      def fallback_filters
        @filter = params[:filter]

        @filter['user_id'] = @user.id if @user

        @filter['budget_period_ids'] ||= []
        @filter['budget_period_ids'].delete('multiselect-all')

        @filter['group_ids'] ||= []
        if @filter['organization_id'].blank?
          @filter['organization_id'] = nil
        end
        @filter['priorities'] ||= []
        @filter['states'] ||= []
        session[:requests_filter] = @filter
      end

      def sort_requests(requests, sort_by, sort_dir)
        r = requests.sort do |a, b|
          case sort_by
          when 'total_price'
              a.total_price(current_user) <=> b.total_price(current_user)
          when 'state'
              Request::STATES.index(a.state(current_user)) <=> \
                Request::STATES.index(b.state(current_user))
          when 'department'
              a.organization.parent.to_s.downcase <=> \
                b.organization.parent.to_s.downcase
          when 'article_name', 'user'
              a.send(sort_by).to_s.downcase <=> \
                b.send(sort_by).to_s.downcase
          else
              a.send(sort_by) <=> \
                b.send(sort_by)
          end
        end
        r.reverse! if sort_dir == 'desc'
        r
      end
    end

  end
end
