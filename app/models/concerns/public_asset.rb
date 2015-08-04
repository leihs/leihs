module PublicAsset
  extend ActiveSupport::Concern

  included do
    attr_writer :public_filename
    attr_accessor :file_file_name
    attr_accessor :file_file_size
  end

  def base64_string=(v)
    data = StringIO.new(Base64.decode64(v))
    data.class.class_eval { attr_accessor :original_filename, :content_type }
    data.original_filename = self.filename
    data.content_type = self.content_type
    self.file = data
  end

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
    partitioned_path = ('%08d' % id).scan(/..../).join('/')
    "#{self.class::PATH_PREFIX}/#{partitioned_path}/#{filename}"
  end

  def destroy_original_file
    File.delete("#{Rails.root}/public#{public_filename}")
  end

  def destroy_thumbnail
    File.delete("#{Rails.root}/public#{public_filename(:thumb)}")
  end

  module ClassMethods
    def define_attached_file_specification **options
      attr_accessor :file_content_type

      # paperclip gem
      has_attached_file \
        :file,
        url: ':public_filename',
        path: ':rails_root/public:url',
        **options
    end
  end
end
