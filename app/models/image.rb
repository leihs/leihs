class Image < ActiveRecord::Base

    belongs_to :model
    
    has_attachment :size => 4.kilobytes..8.megabytes,
                   :content_type => :image, :resize_to => '640x480>',
                   :thumbnails => { :thumb => '100x100>' },
                   :storage => :file_system, :path_prefix => 'public/images/attachments'

    validates_as_attachment

    
####################################

  # alias for serialization
  def public_filename_thumb
    public_filename(:thumb)
  end
    
end
