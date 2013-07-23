class Borrow::ToPickUpController < Borrow::ApplicationController

  def index
    @grouped_and_merged_lines = Visit.grouped_and_merged_lines_for_collection :start_date, current_user.visits.hand_over
  end

end
