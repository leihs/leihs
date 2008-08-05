class Image < ActiveRecord::Base

    belongs_to :model
    
    has_attachment :size => 4.kilobytes..500.kilobytes,
                   :content_type => :image, :resize_to => '320x200>',
                   :thumbnails => { :thumb => '100x100>' },
                   :storage => :file_system, :path_prefix => 'public/images/attachments'

    validates_as_attachment
    
end
