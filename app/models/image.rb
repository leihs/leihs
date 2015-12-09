class Image < ActiveRecord::Base
  include PublicAsset
  audited

  PATH_PREFIX = '/images/attachments'

  belongs_to :target, polymorphic: true

  define_attached_file_specification styles: { original: '640x480>',
                                               thumb: '100x100>' }
  validates_attachment_size :file,
                            greater_than: 4.kilobytes,
                            less_than: 8.megabytes
  validates_attachment_content_type :file, content_type: %r{^image\/(png|gif|jpeg)}

  validates_presence_of :target, if: ->(image) { image.parent_id.nil? }
  validate do
    if Image.where(target_id: target_id, target_type: 'ModelGroup').exists?
      errors.add(:base, _('Category can have only one image.'))
    end
  end

  # paperclip callback
  def destroy_attached_files
    destroy_original_file
    destroy_thumbnail
  end

end
