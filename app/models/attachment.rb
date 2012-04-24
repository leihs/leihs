class Attachment < ActiveRecord::Base

    PATH_PREFIX = "/attachments"

    belongs_to :model

=begin    
    has_attachment :size => 1.kilobytes..100.megabytes,
                   :storage => :file_system, :path_prefix => 'public/attachments'

    validates_as_attachment
=end

####################################
# TODO merge with image.rb 
  
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
       
end
