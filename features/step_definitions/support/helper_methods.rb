def get_rails_model_name_from_url
  path_array_reversed = current_path.split("/").reverse

  case path_array_reversed.first
  when "new"
    path_array_reversed[1].chomp("s")
  when "edit"
    path_array_reversed[2].chomp("s")
  else
    raise 'Unspecified action'
  end
end
