class Article < ActiveRecord::Base
  # With default error messages.
  validates_presence_of :title
  validates_length_of :description, :minimum => 10

  # With your own message with L10n. 
  # old style(Backward compatibility).
  # blog.po in RAILS_ROOT/po/*/ is used.
#  validates_presence_of :title, :message => N_("can't be empty")
#  validates_length_of :description, :minimum => 10, :message => N_("is too short (min is %d characters)")

  # new style (you can use %{fn} and %d freely in the message)
  # blog.po in RAILS_ROOT/po/*/ is used.
#  validates_presence_of :title, :message => N_("%{fn} can't be empty!")
#  validates_length_of :description, :minimum => 10, :message => N_("%{fn} is too short (min is %d characters)")
end
