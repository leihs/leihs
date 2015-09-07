module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /^the home\s?page$/
      '/'

    when /^the borrow$/
      '/borrow'

    when /^the backend$/
      '/backend'

    when /logout/
      '/logout'

    when /^the settings page$/
      '/admin/settings'

    when /^the inventory helper screen$/
      manage_inventory_helper_path @current_inventory_pool

    when /^the main category list$/
      borrow_root_path

    when /^the page showing my documents$/
      borrow_user_documents_path

    when /^this (item|license)'s edit page$/
      manage_edit_item_path @current_inventory_pool, @item

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /^the (.*) page$/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue NoMethodError, ArgumentError
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
