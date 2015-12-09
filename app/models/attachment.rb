class Attachment < ActiveRecord::Base
  include PublicAsset
  audited

  PATH_PREFIX = '/attachments'

  belongs_to :model, inverse_of: :attachments

  define_attached_file_specification
  validates_attachment_size :file, less_than: 100.megabytes
  validates_attachment_content_type \
    :file,
    content_type: %r{^(image\/(png|gif|jpeg)|application\/pdf)}

  # paperclip callback
  def destroy_attached_files
    destroy_original_file
  end

end
