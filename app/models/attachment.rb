class Attachment < ActiveRecord::Base

    belongs_to :model
    
    has_attachment :size => 1.kilobytes..20.megabytes,
                   :storage => :file_system, :path_prefix => 'public/attachments'

    validates_as_attachment

       
end
