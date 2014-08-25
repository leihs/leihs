class Image < ActiveRecord::Base

  PATH_PREFIX = "/images/attachments"

  belongs_to :target, :polymorphic => true

  has_attached_file :file,
                    :url => ":public_filename",
                    :path => ':rails_root/public:url',
                    :styles => { :original => "640x480>", :thumb => '100x100>' }

  attr_accessor :file_file_name
  attr_accessor :file_file_size
  attr_accessor :file_content_type

  validates_presence_of :target, if: ->(image) { image.parent_id.nil? }
  validates_attachment_size :file, :greater_than => 4.kilobytes, :less_than => 8.megabytes

  validates_attachment_content_type :file, :content_type => /^image\/(png|gif|jpeg)/

  validate do
    errors.add(:base, _("Category can have only one image.")) if Image.where(target_id: target_id, target_type: "ModelGroup").exists?
  end

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
    File.delete("#{Rails.root}/public#{public_filename(:thumb)}")
  end

####################################
# TODO merge with attachment.rb 
  
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

