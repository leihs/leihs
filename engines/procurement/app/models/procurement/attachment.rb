module Procurement
  class Attachment < ActiveRecord::Base

    belongs_to :request, inverse_of: :attachments

    validates_presence_of :request

    has_attached_file :file
    validates_attachment_content_type :file, content_type: /.*/
  end
end
