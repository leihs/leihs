class Topic < ActiveRecord::Base
  has_many :replies, :dependent => :destroy, :foreign_key => "parent_id"
  serialize :content

  N_("Topic|Terms of service")
  N_("must be abided")
  
  before_create  :default_written_on
  before_destroy :destroy_children

  def parent
    Topic.find(parent_id)
  end

  def topic_id
    id
  end
  
  protected
    def approved=(val)
      @custom_approved = val
      write_attribute(:approved, val)
    end

    def default_written_on
      self.written_on = Time.now unless attribute_present?("written_on")
    end

    def destroy_children
      self.class.delete_all "parent_id = #{id}"
    end

    def after_initialize
      if self.new_record?
        self.author_email_address = 'test@test.com'
      end
    end
end
