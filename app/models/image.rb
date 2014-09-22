class Image < ActiveRecord::Base
  include PublicAsset

  PATH_PREFIX = "/images/attachments"

  belongs_to :target, :polymorphic => true

  define_attached_file_specification styles: { :original => "640x480>", :thumb => '100x100>' }

  attr_accessor :file_content_type

  validates_presence_of :target, if: ->(image) { image.parent_id.nil? }
  validates_attachment_size :file, :greater_than => 4.kilobytes, :less_than => 8.megabytes

  validates_attachment_content_type :file, :content_type => /^image\/(png|gif|jpeg)/

  validate do
    errors.add(:base, _("Category can have only one image.")) if Image.where(target_id: target_id, target_type: "ModelGroup").exists?
  end

  # paperclip callback
  def destroy_attached_files
    destroy_original_file
    destroy_thumbnail
  end

end
