class Mailer < ActionMailer::Base
  def multipart
    @recipients = "mutoh@highway.ne.jp"
    @from = "mutoh@highway.ne.jp"
    @subject = _("multipart test mail")
    @sent_on = Time.gm("2007-01-01 00:00:00")
    @mime_version = "1.0"
    @body = nil
    @charset = nil
    @content_type = "multipart/mixed"

    attachments = Dir.glob("#{RAILS_ROOT}/public/images/*").select{|f| File.file?(f)}

    part(:content_type => "text/plain", :charset => "iso-2022-jp") do |coverpage|
      coverpage.body = render_message("coverpage", :name => "foo")
      coverpage.transfer_encoding = "7bit"
    end

    attachments.each do |attachment|
      attachment "application/octet-stream" do |attach|
        attach.content_disposition = "attachment"
        attach.charset = nil
        attach.filename = File.basename(attachment)
        attach.transfer_encoding = "base64"
        attach.body = File.read(attachment)
      end
    end
    @body
  end

  def singlepart
    recipients "mutoh@highway.ne.jp"
    from "mutoh@highway.ne.jp"
    subject _("singlepart test mail")
    sent_on Time.gm("2007-01-01 00:00:00")
    body["name"] = "foo"
  end
end
