# == Schema Information
#
# Table name: attachments
#
#  id           :integer(4)      not null, primary key
#  model_id     :integer(4)
#  is_main      :boolean(1)      default(FALSE)
#  content_type :string(255)
#  filename     :string(255)
#  size         :integer(4)
#

# == Schema Information
#
# Table name: attachments
#
#  id           :integer(4)      not null, primary key
#  model_id     :integer(4)
#  is_main      :boolean(1)      default(FALSE)
#  content_type :string(255)
#  filename     :string(255)
#  size         :integer(4)
#
class Attachment < ActiveRecord::Base

    belongs_to :model
    
    has_attachment :size => 1.kilobytes..100.megabytes,
                   :storage => :file_system, :path_prefix => 'public/attachments'

    validates_as_attachment

       
end
