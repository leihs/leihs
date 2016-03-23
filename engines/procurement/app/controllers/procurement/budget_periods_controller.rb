require_dependency 'procurement/application_controller'

module Procurement
  class BudgetPeriodsController < ApplicationController

    before_action do
      authorize BudgetPeriod
    end

    def index
      @budget_periods = BudgetPeriod.order(end_date: :asc)
    end

    def create
      errors = create_or_update_or_destroy

      if errors.empty?
        flash[:success] = _('Saved')
        head status: :ok
      else
        render json: errors, status: :internal_server_error
      end
    end

    def destroy
      BudgetPeriod.find(params[:id]).destroy
      redirect_to budget_periods_path
    end

    private

    def create_or_update_or_destroy
      params.require(:budget_periods).map do |param|
        permitted = param.permit(:name, :inspection_start_date, :end_date)
        unless param[:id].blank?
          bp = BudgetPeriod.find(param[:id])
          if permitted.values.all? &:blank?
            bp.destroy
          else
            bp.update_attributes(permitted)
          end
        else
          next if permitted.values.all? &:blank?
          bp = BudgetPeriod.create(permitted)
        end
        bp.errors.full_messages
      end.flatten.compact
    end
  end
end
