module LeihsAdmin
  class AuditsController < AdminController

    def index
      if params[:start_date].blank?
        params[:start_date] = I18n.l(30.days.ago.to_date)
      end
      params[:end_date] = I18n.l(Time.zone.today) if params[:end_date].blank?

      table = Audited::Adapters::ActiveRecord::Audit.arel_table
      requests = get_requests(table)
      requests = requests.where(user_id: params[:user_id]) if params[:user_id]

      per_page = 10
      page = (params[:page] || 1).to_i
      @audits = \
        requests
          .group_by(&:request_uuid)
          .values[per_page * (page - 1), per_page]

      respond_to do |format|
        format.html
        format.js do
          render partial: 'leihs_admin/audits/audits', collection: @audits
        end
      end
    end

    private

    def get_requests(table)
      if params[:type] and params[:id]
        auditable = params[:type].camelize.constantize.find(params[:id])
        auditable.audits
      else
        Audited::Adapters::ActiveRecord::Audit
      end
        .where(table[:created_at]
        .gteq(Date.parse(params[:start_date])
        .to_s(:db)))
        .where(table[:created_at]
                   .lteq(Date.parse(params[:end_date])
                   .tomorrow
                   .to_s(:db)))
          .order(created_at: :desc, id: :desc)
          .joins('LEFT JOIN users ON users.id = audits.user_id')
          .select("audits.*, CONCAT_WS(' ', users.firstname, users.lastname) " \
                  'AS user_name')
    end
  end
end
