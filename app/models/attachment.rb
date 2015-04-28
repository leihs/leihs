class Attachment < ActiveRecord::Base
  include PublicAsset

  PATH_PREFIX = '/attachments'

  belongs_to :model, inverse_of: :attachments

  define_attached_file_specification

  validates_attachment_size :file, less_than: 100.megabytes

  # paperclip callback
  def destroy_attached_files
    destroy_original_file
  end

end
