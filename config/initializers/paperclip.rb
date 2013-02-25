Paperclip.interpolates :public_filename do |attachment, style|
  attachment.instance.public_filename(style)
end