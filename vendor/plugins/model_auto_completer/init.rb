# We include the modules via Object#send because Module#include is private.

ActionView::Base.send(:include, ModelAutoCompleterHelper)
ActionController::Base.send(:include, ModelAutoCompleter)