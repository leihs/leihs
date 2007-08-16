require File.dirname(__FILE__) + '/../test_helper'
require 'leihs_mailer'

class LeihsMailerTest < Test::Unit::TestCase
	
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  include ActionMailer::Quoting

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
  end

  def test_aktivierung
    #@expected.subject = 'LeihsMailer#aktivierung'
    #@expected.body    = read_fixture('aktivierung')
    #@expected.date    = Time.now

    #assert_equal @expected.encoded, LeihsMailer.create_aktivierung(@expected.date).encoded
  end

  def test_benachrichtigung
    #@expected.subject = 'LeihsMailer#benachrichtigung'
    #@expected.body    = read_fixture('benachrichtigung')
    #@expected.date    = Time.now

    #assert_equal @expected.encoded, LeihsMailer.create_benachrichtigung(@expected.date).encoded
  end

  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/leihs_mailer/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end
