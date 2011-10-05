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

    PATH_PREFIX = "/images/attachments"

    belongs_to :model

    # TODO MiniMagick upload, resize, etc...
    # TODO store thumbnails in Base64 directly to the database ??
        
#old#
=begin 
    has_attachment :size => 4.kilobytes..8.megabytes,
                   :content_type => :image, :resize_to => '640x480>',
                   :thumbnails => { :thumb => '100x100>' },
                   :storage => :file_system, :path_prefix => 'public/images/attachments'

    validates_as_attachment
=end
    
####################################

  # NOTE copied from attachment_fu
  # Gets the thumbnail name for a filename.  'foo.jpg' becomes 'foo_thumbnail.jpg'
  def thumbnail_name_for(thumbnail = nil)
    return filename if thumbnail.blank?
    ext = nil
    basename = filename.gsub /\.\w+$/ do |s|
      ext = s; ''
    end
    "#{basename}_#{thumbnail}#{ext}"
  end

  def public_filename(thumb = nil)
    partitioned_path = ("%08d" % id).scan(/..../).join('/')
    filename = thumbnail_name_for(thumb) 
    "#{PATH_PREFIX}/#{partitioned_path}/#{filename}"
  end

  # alias for serialization
  def public_filename_thumb
    public_filename(:thumb)
  end
    
end

