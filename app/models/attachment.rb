class Attachment < ActiveRecord::Base

  PATH_PREFIX = "/attachments"

  belongs_to :model, inverse_of: :attachments

  # paperclip gem
  has_attached_file :file,
                    :url => ":public_filename",
                    :path => ':rails_root/public:url'
  validates_attachment_size :file, :less_than => 100.megabytes
  attr_accessor :file_file_name
  attr_accessor :file_file_size

  def base64_string=(v)
    data = StringIO.new(Base64.decode64(v))
    data.class.class_eval { attr_accessor :original_filename, :content_type }
    data.original_filename = self.filename
    data.content_type = self.content_type
    self.file = data
  end

  # paperclip callback
  def destroy_attached_files
    File.delete("#{Rails.root}/public#{public_filename}")
  end

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

  # defined as Paperclip.interpolates
  def public_filename(thumb = nil)
    thumb = nil if thumb == :original
    filename = thumbnail_name_for(thumb)
    partitioned_path = ("%08d" % id).scan(/..../).join('/')
    "#{PATH_PREFIX}/#{partitioned_path}/#{filename}"
  end
  attr_writer :public_filename

end
