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
        @filter['category_ids'] ||= begin
          r = Procurement::CategoryInspector.where(user_id: current_user) \
            .pluck(:category_id)
          r = Procurement::Category.ids if r.empty?
          r
        end
        @filter['organization_ids'] ||= Procurement::Organization.ids
        @filter['priorities'] ||= ['high', 'normal']
        @filter['inspector_priorities'] ||= %w(mandatory high medium low)
        @filter['states'] ||= Procurement::Request::STATES

        @filter['sort_by'] = 'state' if @filter['sort_by'].blank?
        @filter['sort_dir'] = 'asc' if @filter['sort_dir'].blank?
      end

      # rubocop:disable Metrics/MethodLength
      def get_requests
        fallback_filters

        @categories = if @filter['inspectable_categories'] == '1'
                        Procurement::Category.inspectable_by(current_user)
                      else
                        Procurement::Category.where(id: @filter['category_ids'])
                      end

        h = {}
        Procurement::BudgetPeriod.order(end_date: :desc) \
          .find(@filter['budget_period_ids']).each do |budget_period|

          k = { category_id: @categories,
                organization_id: @filter['organization_ids'],
                priority: @filter['priorities'],
                inspector_priority: @filter['inspector_priorities'] }
          k[:user_id] = @user if @user

          requests = budget_period.requests.search(@filter['search']).where(k)

          requests = requests.select do |r|
            @filter['states'].map(&:to_sym).include? r.state(current_user)
          end

          h[budget_period] = sort_requests(requests,
                                           @filter['sort_by'],
                                           @filter['sort_dir'])
        end
        h
      end
      # rubocop:enable Metrics/MethodLength

      private

      # rubocop:disable Metrics/MethodLength
      def fallback_filters
        @filter = params[:filter]

        @filter['user_id'] = @user.id if @user

        unless (procurement_inspector? or procurement_admin?)
          @filter['categories_with_requests'] ||= '1'
        end

        @filter['budget_period_ids'] ||= []
        @filter['budget_period_ids'].delete('multiselect-all')

        @filter['category_ids'] ||= []
        @filter['category_ids'].delete('multiselect-all')

        if procurement_inspector? or procurement_admin?
          @filter['organization_ids'] ||= []
        else
          @filter['organization_ids'] = Procurement::Organization.ids
        end
        @filter['organization_ids'].delete('multiselect-all')

        @filter['priorities'] ||= []
        if procurement_inspector? or procurement_admin?
          @filter['inspector_priorities'] ||= []
        else
          @filter['inspector_priorities'] ||= %w(mandatory high medium low)
        end
        @filter['states'] ||= []
        session[:requests_filter] = @filter
      end
      # rubocop:enable Metrics/MethodLength

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
