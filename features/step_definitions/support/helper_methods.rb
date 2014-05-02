def get_rails_model_name_from_url
  path_array_reversed = current_path.split("/").reverse

  model_name = case path_array_reversed.first
               when "new"
                 path_array_reversed[1].chomp("s")
               when "edit"
                 id = path_array_reversed[1].chomp("s")
                 path_array_reversed[2].chomp("s")
               else
                 raise 'Unspecified action'
               end

  model_name = "software" if model_name == "model" and ( current_url =~ /type=software/ or Model.find(id).is_a?(Software) )
  model_name
end
