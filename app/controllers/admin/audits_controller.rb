class Admin::AuditsController < Admin::ApplicationController

  def index
    params[:start_date] = I18n.l(30.days.ago.to_date) if params[:start_date].blank?
    params[:end_date] = I18n.l(Date.today) if params[:end_date].blank?

    table = Audited::Adapters::ActiveRecord::Audit.arel_table

    requests = if params[:type] and params[:id]
                 auditable = params[:type].camelize.constantize.find(params[:id])
                 auditable.audits
               else
                 Audited::Adapters::ActiveRecord::Audit
               end.
        where(table[:created_at].gteq(Date.parse(params[:start_date]).to_s(:db))).
        where(table[:created_at].lteq(Date.parse(params[:end_date]).tomorrow.to_s(:db))).
        order(created_at: :desc, id: :desc)

    requests = requests.where(user_id: params[:user_id]) if params[:user_id]

    @requests = requests.group_by { |x| x.request_uuid }
  end

end
