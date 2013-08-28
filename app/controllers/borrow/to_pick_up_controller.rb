class Borrow::ToPickUpController < Borrow::ApplicationController

  def index
    @grouped_and_merged_lines = Visit.grouped_and_merged_lines current_user.visits.hand_over.flat_map(&:lines)
  end

end
