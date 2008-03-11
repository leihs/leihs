require File.dirname(__FILE__) + '/../test_helper'

class OrderMailerTest < ActionMailer::TestCase
  tests OrderMailer
  def test_approved
    @expected.subject = 'OrderMailer#approved'
    @expected.body    = read_fixture('approved')
    @expected.date    = Time.now

    assert_equal @expected.encoded, OrderMailer.create_approved(@expected.date).encoded
  end

  def test_rejected
    @expected.subject = 'OrderMailer#rejected'
    @expected.body    = read_fixture('rejected')
    @expected.date    = Time.now

    assert_equal @expected.encoded, OrderMailer.create_rejected(@expected.date).encoded
  end

  def test_changed
    @expected.subject = 'OrderMailer#changed'
    @expected.body    = read_fixture('changed')
    @expected.date    = Time.now

    assert_equal @expected.encoded, OrderMailer.create_changed(@expected.date).encoded
  end

end
