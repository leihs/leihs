require 'digest/sha1'

module ModelAutoCompleterHelper
  # Generates a text field that autocompletes a <tt>belongs_to</tt> association,
  # and a hidden field managed with JavaScript that stores the ID of selected
  # models.
  #
  # Say we have these models:
  #
  #   class Author < ActiveRecord::Base
  #     has_many :books
  #   end
  #
  #   class Book < ActiveRecord::Base
  #     belongs_to :author
  #   end
  #
  # In the form to edit books you can just do this to assign an author by autocompletion
  # on her name:
  #
  #   <%= belongs_to_auto_completer :book, :author, :name %>
  #
  # We assume here <tt>BooksController</tt> implements an action called
  # <tt>auto_complete_belongs_to_for_book_author_name</tt>:
  #
  #   def auto_complete_belongs_to_for_book_author_name
  #     @authors = Author.find(
  #       :all,
  #       :conditions => ['LOWER(name) LIKE ?', "%#{params[:author][:name]}%"],
  #       :limit => 10
  #     )
  #     render :inline => '<%= model_auto_completer_result(@authors, :name) %>'
  #   end
  #
  # though that can be configured, see options below.
  #
  # There is convenience class method for controllers +auto_complete_belongs_to_for+
  # which generates a default action, analogous to the one in the standard autocompleter.
  #
  # The text field is named "<em>association[method]</em>", in the example "author[name]".
  # We don't include the object so that <tt>params[:book]</tt> does not contain that
  # auxiliary value.
  #
  # The hidden field is named "<em>object[association_foreign_key]</em>", in the example that
  # is "book[author_id]". The goal is that regular mass-assignement idioms like
  # <tt>Book.new(params[:book])</tt> work as usual and are all you need to associate the
  # author. The name of the foreign key is figured out dynamically by reflection on the
  # association.
  #
  # See the documentation of <tt>model_auto_completer</tt> for further details and
  # options. This helper is just a convenience wrapper for that one.
  def belongs_to_auto_completer(object, association, method, options={}, tag_options={}, completion_options={})
    real_object  = instance_variable_get("@#{object}")
    foreign_key  = real_object.class.reflect_on_association(association).primary_key_name

    tf_name  = "#{association}[#{method}]"
    tf_value = (real_object.send(association).send(method) rescue nil)
    hf_name  = "#{object}[#{foreign_key}]"
    hf_value = (real_object.send(foreign_key) rescue nil)
    options  = {
      :action => "auto_complete_belongs_to_for_#{object}_#{association}_#{method}"
    }.merge(options)
    model_auto_completer(tf_name, tf_value, hf_name, hf_value, options, tag_options, completion_options)
  end

  # Returns an unordered HTML list of completion results that is understood
  # by the client code right away. This is meant to be used by controllers
  # this way:
  #
  #   render :inline => '<%= model_auto_completer_result(@users, :fullname) %>'
  #
  # The string shown per model is the result of invoking +display+ on them.
  #
  # If you pass a +phrase+ it will be highlighted in each entry.
  def model_auto_completer_result(models, display, phrase=nil)
    # We can't assume dom_id(model) is available because the plugin does not require Rails 2 by now.
    prefix = models.first.class.name.underscore.tr('/', '_') unless models.empty?
    items = models.map do |model|
      li_id      = "#{prefix}_#{model.id}"
      li_content = model.send(display)
      content_tag('li', (phrase ? highlight(li_content, phrase) : h(li_content)), :id => li_id)
    end
    content_tag('ul', items.uniq)
  end

  # This is the most generic helper for model autocompletion. This widget
  # creates a text field and manages a hidden field where the ID of the
  # selected model is stored.
  #
  # Autocompletion itself is delegated to the standard Rails autocompleter. You
  # can pass options for it in the rightmost argument. For example, to disable
  # inline CSS pass <tt>:skip_style => true</tt>.
  #
  # By default, the name of the action to invoke is +auto_complete_model_for_+
  # and a suffix computed from the text field name (+tf_name+). If the text field
  # is called "owner[fullname]" we obtain +auto_complete_model_for_owner_fullname+,
  # you see how it works. The text field initially contains +tf_value+.
  #
  # Note that +model_auto_completer+ itself uses the underlying callback
  # <tt>:after_update_element</tt> to extract the model and do some housekeeping.
  # If you need a callback use the provided wrapper instead, which in addition
  # receives the hidden field and the extracted model id. See options below.
  #
  # The hidden field will be named +hf_name+ and will have an initial value
  # of +hf_value+.
  #
  # Generated INPUT elements have a random suffix in their <tt>id</tt>s so that
  # you can include this widget more than once in the same page with negligible
  # risk of collision. You can turn this off via <tt>:append_random_suffix</tt>.
  #
  # The widget expects a regular unordered list of completions as you send
  # for the standard Rails autocompleter, except list items are required to
  # have an +id+ attribute.
  #
  # By default, any trailing integers in the +id+ attributes will be considered to
  # be the identifiers of the corresponding models. There's a configurable regexp
  # to extract them though, see options below.
  #
  # Normally you are done sending the completion list with something like
  #
  #   render :inline => '<%= model_auto_completer_result(@authors, :name) %>'
  #
  # But the actual contract is to send back a HTML list, where the content of
  # the items may have arbitrary stuff:
  #
  #   <ul>
  #     <% for author in @authors %>
  #     <li id="<%= dom_id(author) %>">
  #       <%= avatar(author) %> <%=h author.name %>
  #     </li>
  #     <% end %>
  #   </ul>
  #
  # the helper +model_auto_completer_result+ generates something like that.
  #
  # Available options are:
  #
  # * <tt>:regexp_for_id</tt>: A regexp with at least one group. The first
  #   capture is assumed to be the ID of the corresponding model. Defaults to
  #   <tt>(\d+)$</tt>.
  #
  # * <tt>:allow_free_text</tt>: If +false+ the widget only allows values that
  #   come from autocompletion. If the user leaves the text field with a free
  #   string the text field is rolled back to the last valid value. If +true+
  #   free edition is allowed, and if the text field contains free text the
  #   hidden field will contain the empty string. Defauts to +false+.
  #
  # * <tt>:append_random_suffix</tt>: If +true+ the HTML id of the generated
  #   fields gets a random suffix to avoid collisions in case you put
  #   the widget more than once in the same page. Defaults to +true+.
  #   (Since 1.5.)
  #
  # * <tt>:submit_on_return</tt>: Some browsers submit the form if you select
  #   and item from the completion list with the keyboard. If this flag is off
  #   the return key is captured and discarded. Defaults to +false+. (Since 1.5.)
  #
  # * <tt>:send_on_return</tt>: Deprecated. Alias for <tt>:submit_on_return</tt> that is
  #   available for backwards compatibility.
  #
  # * <tt>:after_update_element</tt>: A JavaScript function that is called when
  #   the user has selected one of the completions. It gets four arguments, the
  #   text field, the selected list item, the hidden field, and the extracted
  #   model id.
  #
  # * <tt>:url</tt>: The URL that provides completions. Use this for named routes.
  #   If this option has a value <tt>:controller</tt> and <tt>:action</tt> are just
  #   ignored. (Since 1.5.)
  #
  # * <tt>:controller</tt>: The controller that implements the action that
  #   returns completions. Defaults to the current controller.
  #
  # * <tt>:action</tt>: The action that provides the completions. The default
  #   is explained above.
  def model_auto_completer(tf_name, tf_value, hf_name, hf_value, options={}, tag_options={}, completion_options={})
    options = {
      :regexp_for_id        => '(\d+)$',
      :append_random_suffix => true,
      :allow_free_text      => false,
      :submit_on_return     => false,
      :controller           => controller.controller_name,
      :action               => 'auto_complete_model_for_' + tf_name.sub(/\[/, '_').gsub(/\[\]/, '_').gsub(/\[?\]$/, ''),
      :after_update_element => 'Prototype.emptyFunction'
    }.merge(options)
    options[:submit_on_return] = options[:send_on_return] if options[:send_on_return]

    hf_id, tf_id = determine_field_ids(options)
    determine_tag_options(hf_id, tf_id, options, tag_options)
    determine_completion_options(hf_id, options, completion_options)

    return <<-HTML
      #{auto_complete_stylesheet unless completion_options[:skip_style]}
      #{hidden_field_tag(hf_name, hf_value, :id => hf_id)}
      #{text_field_tag tf_name, tf_value, tag_options}
      #{content_tag("div", "", :id => "#{tf_id}_auto_complete", :class => "auto_complete")}
      #{auto_complete_field tf_id, completion_options}
    HTML
  end

private

  def determine_field_ids(options)
    hf_id = 'model_auto_completer_hf'
    tf_id = 'model_auto_completer_tf'
    if options[:append_random_suffix]
      rand_id = Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by {rand}.join)
      hf_id << "_#{rand_id}"
      tf_id << "_#{rand_id}"
    end
    return hf_id, tf_id
  end

  def determine_tag_options(hf_id, tf_id, options, tag_options) #:nodoc:
    tag_options.update({
      :id      => tf_id,
      # Cache the default text field value when the field gets focus.
      :onfocus => 'if (this.model_auto_completer_cache == undefined) {this.model_auto_completer_cache = this.value}'
    })

    # When the user is done editing the text field we need to check its consistency. To be
    # able to do that we add an onchange event handler to the text field.
    #
    # When the user clicks with the mouse on the completion list there's a race
    # condition: model_auto_completer is assigned to in a callback, and this
    # handler is invoked, which uses the cache as well. This often resulted in
    # corrupt strings if the user selected two models with the mouse. That's
    # why we use a small delay. Looks like 200 milliseconds are enough.
    tag_options[:onchange] = if options[:allow_free_text]
      "window.setTimeout(function () {if (this.value != this.model_auto_completer_cache) {$('#{hf_id}').value = ''}}.bind(this), 200)"
    else
      "window.setTimeout(function () {this.value = this.model_auto_completer_cache}.bind(this), 200)"
    end

    unless options[:submit_on_return]
      tag_options[:onkeypress] = 'return event.keyCode == Event.KEY_RETURN ? false : true'
    end
  end

  # Determines the actual completion options, taken into account the ones from
  # the user.
  def determine_completion_options(hf_id, options, completion_options) #:nodoc:
    # model_auto_completer does most of its work in the afterUpdateElement hook of the
    # standard autocompletion mechanism. Here we generate the JavaScript that goes there.
    completion_options[:after_update_element] = <<-JS.gsub(/\s+/, ' ')
      function(element, value) {
          var model_id = /#{options[:regexp_for_id]}/.exec(value.id)[1];
          $("#{hf_id}").value = model_id;
          element.model_auto_completer_cache = element.value;
          (#{options[:after_update_element]})(element, value, $("#{hf_id}"), model_id);
      }
    JS

    # :url has higher priority than :action and :controller.
    completion_options[:url] = options[:url] || url_for(
      :controller => options[:controller],
      :action     => options[:action]
    )
  end
end