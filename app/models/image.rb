# == Schema Information
#
# Table name: images
#
#  id           :integer(4)      not null, primary key
#  model_id     :integer(4)
#  is_main      :boolean(1)      default(FALSE)
#  content_type :string(255)
#  filename     :string(255)
#  size         :integer(4)
#  height       :integer(4)
#  width        :integer(4)
#  parent_id    :integer(4)
#  thumbnail    :string(255)
#

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

