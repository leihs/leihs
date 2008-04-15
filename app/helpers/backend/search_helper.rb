module Backend::SearchHelper
  
  ACTION_DICTIONARY = { "add_line" => ["Add", "package_add"],
                        "swap_line" => ["Swap", "arrow_switch"]}
  
  def get_action_text(action)
    ACTION_DICTIONARY[action][0]
  end

  def get_action_image(action)
    ACTION_DICTIONARY[action][1]
  end

    
end
