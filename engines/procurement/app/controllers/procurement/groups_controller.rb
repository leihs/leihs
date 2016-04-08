require_dependency 'procurement/application_controller'

module Procurement
  class GroupsController < ApplicationController

    before_action do
      authorize Group
    end

    before_action only: [:create, :update] do
      params[:group][:inspector_ids] = \
        params[:group][:inspector_ids].split(',').map &:to_i
    end

    before_action only: [:edit, :update, :destroy] do
      @group = Group.find(params[:id])
    end

    def index
      @groups = Group.all
      respond_to do |format|
        format.html
        format.json { render json: @groups }
      end
    end

    def new
      @group = Group.new
      render :edit
    end

    def create
      @group = Group.create(params[:group])
      if @group.valid?
        redirect_to groups_path
      else
        flash.now[:error] = @group.errors.full_messages
        render :edit
      end
    end

    def edit
    end

    def update
      @group.update_attributes(params[:group])
      flash[:success] = _('Saved')
      redirect_to groups_path
    end

    def destroy
      @group.destroy
      redirect_to groups_path
    end

  end
end
