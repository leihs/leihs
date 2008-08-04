require File.dirname(__FILE__) + '/../test_helper'
require 'mailer_controller'

unless defined? RESULT_DIR
  RESULT_DIR = File.dirname(__FILE__) + "/../../test/result/"
end

# Re-raise errors caught by the controller.
class MailerController; def rescue_action(e) raise e end; end

class MailerControllerTest < Test::Unit::TestCase
  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @controller = MailerController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def save_html(path, data)
    open(RESULT_DIR + path, "w"){|io| io.write data}
  end

  def assert_mail(path, data)
    assert_equal IO.read(RESULT_DIR + path), data
  end

  def mimepart(data)
    data.gsub(/^--mimepart_.*$/, "--mimepart").
      gsub(/boundary\=mimepart_(.*)$/, "boundary=mimepart")
  end

  def assert_multipart(path, data)
    target = mimepart(IO.read(RESULT_DIR + path))
    data = mimepart(data)
    assert_equal target, data
  end

  def assert_html(path, data)
    target = mimepart(IO.read(RESULT_DIR + path)).split("\n").collect{|n| n << "\n"}
    data = mimepart(data)
    
    i = 0
    data.each_line{|line|
      assert_equal target[i], line
      i += 1
    }
  end

  def test_singlepart
    # Japanese
    get :singlepart, :lang => "ja"
    data = ActionMailer::Base.deliveries[0].decoded
    assert_mail("ja/singlepart.html", data)

    # English
    get :singlepart, :lang => "en"
    data = ActionMailer::Base.deliveries[1].decoded
    assert_mail("en/singlepart.html", data)

    # not match -> English
    get :singlepart, :lang => "kr"
    data = ActionMailer::Base.deliveries[2].decoded
    assert_mail("en/singlepart.html", data)

    # singlepart_fr.rhtml
    get :singlepart, :lang => "fr"
    data = ActionMailer::Base.deliveries[3].decoded
    assert_mail("fr/singlepart.html", data)
  end

  def test_multipart
    # Japanese
    get :multipart, :lang => "ja"
    data = ActionMailer::Base.deliveries[0].decoded
    assert_multipart("ja/multipart.html", data)

    # English
    get :multipart, :lang => "en"
    data = ActionMailer::Base.deliveries[1].decoded
    assert_multipart("en/multipart.html", data)

    # not match -> English
    get :multipart, :lang => "kr"
    data = ActionMailer::Base.deliveries[2].decoded
    assert_multipart("en/multipart.html", data)

    # multipart_fr.rhtml
    get :multipart, :lang => "fr"
    data = ActionMailer::Base.deliveries[3].decoded
    assert_multipart("fr/multipart.html", data)
  end
end
