$KCODE = "U"
$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'gettext'
require 'gettext/active_record'
require 'gettext/parser/active_record'
require 'test/unit'
require 'active_record'
require 'active_record/fixtures'
require 'fixtures/topic'
require 'fixtures/reply'
require 'fixtures/developer'
require 'fixtures/wizard'
require 'fixtures/inept_wizard'
require 'logger'

AR_TEST_VERSION = /activerecord-([^\/]+)/.match($:.join)[1]

if AR_TEST_VERSION > "2.0.0"
  #ticket 6657 on dev.rubyonrails.org require this but it becames removed(?)
  AR_6657 = true
else
  AR_6657 = false
end
puts "The activerecord svn version is #{$1}"


begin
  `rake dropdb`
rescue
end
begin
  `rake createdb`
rescue
  p $!
end

ActiveRecord::Base.establish_connection(
  :adapter  => "mysql",
  :username => "root",
  :password => "",
  :encoding => "utf8",
  :socket => "/var/lib/mysql/mysql.sock",
  :database => 'activerecord_unittest'
)

# Make with_scope public for tests
class << ActiveRecord::Base
  public :with_scope, :with_exclusive_scope
end

class Test::Unit::TestCase #:nodoc:
  include GetText
  bindtextdomain("active_record", "locale")
  textdomain_to(ActiveRecord::Base, "active_record")
  textdomain_to(ActiveRecord::Validations, "active_record")
  self.fixture_path = File.dirname(__FILE__) + "/fixtures/"
end

# The following methods in Topic are used in test_conditional_validation_*
class Topic
  def condition_is_true
    return true
  end

  def condition_is_true_but_its_not
    return false
  end
end

class ProtectedPerson < ActiveRecord::Base
  set_table_name 'people'
  attr_accessor :addon
  attr_protected :first_name
end

class MyModel
  attr_accessor :title
  def save; end
  def save!;  end
  def update_attribute(name, value); end
  def new_record?
    false
  end
  def self.human_attribute_name(name)
     name
  end
  include ActiveRecord::Validations

  validates_presence_of :title
end

class Conjurer < IneptWizard
end

class Thaumaturgist < IneptWizard
end

class ValidationsTest < Test::Unit::TestCase
  fixtures :topics, :developers

  def setup
    bindtextdomain_to(Topic, "active_record")

    if AR_TEST_VERSION < "2.1.0"
      Topic.write_inheritable_attribute(:validate, nil)
      Topic.write_inheritable_attribute(:validate_on_create, nil)
      Topic.write_inheritable_attribute(:validate_on_update, nil)
    else
      Topic.instance_variable_set("@validate_callbacks", ActiveSupport::Callbacks::CallbackChain.new)
      Topic.instance_variable_set("@validate_on_create_callbacks", ActiveSupport::Callbacks::CallbackChain.new)
      Topic.instance_variable_set("@validate_on_update_callbacks", ActiveSupport::Callbacks::CallbackChain.new)
    end
  end


  def test_single_attr_validation_and_error_msg
    GetText.set_locale_all "ja_JP.UTF-8"
    r = Reply.new
    r.title = "There's no content!"
    r.save
    assert r.errors.invalid?("content"), "A reply without content should mark that attribute as invalid"
    assert_equal "空です。", r.errors.on("content"), "A reply without content should contain an error"
    assert_equal "Reply内容 空です。", r.errors.full_messages[0], "A reply without content should contain an error"
    assert_equal 1, r.errors.count

    GetText.set_locale_all "en"
    r = Reply.new
    r.title = "There's no content!"
    r.save
    assert_equal "Empty", r.errors.on("content"), "A reply without content should contain an error"
  end

  def test_double_attr_validation_and_error_msg
    GetText.set_locale_all "ja_JP.UTF-8"
    r = Reply.new
    assert !r.save

    assert r.errors.invalid?("title"), "A reply without title should mark that attribute as invalid"
    assert_equal "Replyタイトル 空です。", r.errors.full_messages[0]
    assert_equal "空です。", r.errors.on("title")

    assert r.errors.invalid?("content"), "A reply without content should mark that attribute as invalid"
    assert_equal "Reply内容 空です。", r.errors.full_messages[1]
    assert_equal "空です。", r.errors.on("content")

    assert_equal 2, r.errors.count

    GetText.set_locale_all "en"
    r = Reply.new
    assert !r.save

    assert r.errors.invalid?("title"), "A reply without title should mark that attribute as invalid"
    assert_equal "Title Empty", r.errors.full_messages[0]
    assert_equal "Empty", r.errors.on("title"), "A reply without title should contain an error"

    assert r.errors.invalid?("content"), "A reply without content should mark that attribute as invalid"
    assert_equal "Content Empty", r.errors.full_messages[1]
    assert_equal "Empty", r.errors.on("content"), "A reply without content should contain an error"

    assert_equal 2, r.errors.count
  end

  def test_error_on_create
    GetText.set_locale_all "ja_JP.UTF-8"
    r = Reply.new
    r.title = "Wrong Create"
    assert !r.save
    assert r.errors.invalid?("title"), "A reply with a bad title should mark that attribute as invalid"
    assert_equal "Replyタイトル が不正に生成されました。", r.errors.full_messages[0]
    assert_equal "が不正に生成されました。", r.errors.on("title")

    GetText.set_locale_all "en"
    r = Reply.new
    r.title = "Wrong Create"
    assert !r.save
    assert r.errors.invalid?("title"), "A reply with a bad title should mark that attribute as invalid"
    assert_equal "Title is Wrong Create", r.errors.full_messages[0]
    assert_equal "is Wrong Create", r.errors.on("title")
  end


  def test_error_on_update
    GetText.set_locale_all "ja_JP.UTF-8"
    r = Reply.new
    r.title = "Bad"
    r.content = "Good"
    assert r.save, "First save should be successful"
    r.title = "Wrong Update"
    assert !r.save, "Second save should fail"
    assert r.errors.invalid?("title"), "A reply with a bad title should mark that attribute as invalid"
    assert_equal "Replyタイトル が不正に更新されました。", r.errors.full_messages[0]
    assert_equal "が不正に更新されました。", r.errors.on("title")

    GetText.set_locale_all "en"
    r = Reply.new
    r.title = "Bad"
    r.content = "Good"
    assert r.save, "First save should be successful"

    r.title = "Wrong Update"
    assert !r.save, "Second save should fail"

    assert r.errors.invalid?("title"), "A reply with a bad title should mark that attribute as invalid"
    assert_equal "Title is Wrong Update", r.errors.full_messages[0]
    assert_equal "is Wrong Update", r.errors.on("title")
  end

  def test_invalid_record_exception
    assert_raises(ActiveRecord::RecordInvalid) { Reply.create! }
    assert_raises(ActiveRecord::RecordInvalid) { Reply.new.save! }

    GetText.set_locale_all "ja_JP.UTF-8"
    begin
      r = Reply.new
      r.save!
      flunk
    rescue ActiveRecord::RecordInvalid => invalid
      assert_equal r, invalid.record
      assert_equal "入力値が正しくありません。: Replyタイトル 空です。, Reply内容 空です。", invalid.message
    end

    GetText.set_locale_all "en"
    begin
      r = Reply.new
      r.save!
      flunk
    rescue ActiveRecord::RecordInvalid => invalid
      assert_equal r, invalid.record
      assert_equal "Validation failed: Title Empty, Content Empty", invalid.message
    end
  end

  def test_exception_on_create_bang_many
    assert_raises(ActiveRecord::RecordInvalid) do
      Reply.create!([ { "title" => "OK" }, { "title" => "Wrong Create" }])
    end

    GetText.set_locale_all "ja_JP.UTF-8"
    begin
      Reply.create!([ { "title" => "OK" }, { "title" => "Wrong Create" }])
    rescue ActiveRecord::RecordInvalid => invalid
      assert_equal "入力値が正しくありません。: Reply内容 空です。", invalid.message
    end
    GetText.set_locale_all "en"
    begin
      Reply.create!([ { "title" => "OK" }, { "title" => "Wrong Create" }])
    rescue ActiveRecord::RecordInvalid => invalid
      assert_equal "Validation failed: Content Empty", invalid.message
    end
  end

 
  def test_exception_on_create_bang_with_block
    assert_raises(ActiveRecord::RecordInvalid) do
      Reply.create!({ "title" => "OK" }) do |r|
        r.content = nil
      end
    end

    GetText.set_locale_all "ja_JP.UTF-8"
    begin
      Reply.create!({ "title" => "OK" }) do |r|
        r.content = nil
      end
    rescue ActiveRecord::RecordInvalid => invalid
      assert_equal "入力値が正しくありません。: Reply内容 空です。", invalid.message
    end

    GetText.set_locale_all "en"
    begin
      Reply.create!({ "title" => "OK" }) do |r|
        r.content = nil
      end
    rescue ActiveRecord::RecordInvalid => invalid
      assert_equal "Validation failed: Content Empty", invalid.message
    end
  end

  def test_exception_on_create_bang_many_with_block
    assert_raises(ActiveRecord::RecordInvalid) do
      Reply.create!([{ "title" => "OK" }, { "title" => "Wrong Create" }]) do |r|
        r.content = nil
      end
    end
    GetText.set_locale_all "ja_JP.UTF-8"
    begin
      Reply.create!([{ "title" => "OK" }, { "title" => "Wrong Create" }]) do |r|
        r.content = nil
      end
    rescue ActiveRecord::RecordInvalid => invalid
      assert_equal "入力値が正しくありません。: Reply内容 空です。", invalid.message
    end

    GetText.set_locale_all "en"
    begin
      Reply.create!([{ "title" => "OK" }, { "title" => "Wrong Create" }]) do |r|
        r.content = nil
      end
    rescue ActiveRecord::RecordInvalid => invalid
      assert_equal "Validation failed: Content Empty", invalid.message
    end
  end
  
  def test_scoped_create_without_attributes
    Reply.with_scope(:create => {}) do
      assert_raises(ActiveRecord::RecordInvalid) { Reply.create! }
    end

    GetText.set_locale_all "ja_JP.UTF-8"
    Reply.with_scope(:create => {}) do
      begin
        Reply.create!
      rescue ActiveRecord::RecordInvalid => invalid
        assert_equal "入力値が正しくありません。: Replyタイトル 空です。, Reply内容 空です。", invalid.message
      end
    end

    GetText.set_locale_all "en"
    Reply.with_scope(:create => {}) do
      begin
        Reply.create!
      rescue ActiveRecord::RecordInvalid => invalid
        assert_equal "Validation failed: Title Empty, Content Empty", invalid.message
      end
    end
  end

  def test_single_error_per_attr_iteration
    GetText.set_locale_all "ja_JP.UTF-8"
    r = Reply.new
    r.save

    errors = []
    r.errors.each { |attr, msg| errors << [attr, msg] }

    assert errors.include?(["title", "空です。"])
    assert errors.include?(["content", "空です。"])

    GetText.set_locale_all "en"
    r = Reply.new
    r.save

    errors = []
    r.errors.each { |attr, msg| errors << [attr, msg] }

    assert errors.include?(["title", "Empty"])
    assert errors.include?(["content", "Empty"])
  end

  def test_multiple_errors_per_attr_iteration_with_full_error_composition
    GetText.set_locale_all "ja_JP.UTF-8"
    r = Reply.new
    r.title   = "Wrong Create"
    r.content = "Mismatch"
    r.save

    errors = []
    r.errors.each_full { |error| errors << error }
    assert_equal "Replyタイトル が不正に生成されました。", errors[0]
    assert_equal "Replyタイトル は内容がミスマッチです。", errors[1]
    assert_equal 2, r.errors.count

    GetText.set_locale_all "en"
    r = Reply.new
    r.title   = "Wrong Create"
    r.content = "Mismatch"
    r.save

    errors = []
    r.errors.each_full { |error| errors << error }

    assert_equal "Title is Wrong Create", errors[0]
    assert_equal "Title is Content Mismatch", errors[1]
    assert_equal 2, r.errors.count
  end

  def test_errors_on_base
    GetText.set_locale_all "ja_JP.UTF-8"
    r = Reply.new
    r.content = "Mismatch"
    r.save
    r.errors.add_to_base "リプライはdignifyされてません。"

    errors = []
    r.errors.each_full { |error| errors << error }

    assert_equal "リプライはdignifyされてません。", r.errors.on_base

    assert errors.include?("Replyタイトル 空です。")
    assert errors.include?("リプライはdignifyされてません。")
    assert_equal 2, r.errors.count

    GetText.set_locale_all "en"
    r = Reply.new
    r.content = "Mismatch"
    r.save
    r.errors.add_to_base "Reply is not dignifying"

    errors = []
    r.errors.each_full { |error| errors << error }

    assert_equal "Reply is not dignifying", r.errors.on_base

    assert errors.include?("Title Empty")
    assert errors.include?("Reply is not dignifying")
    assert_equal 2, r.errors.count
  end

  def test_validates_each
    perform = true
    hits = 0
    Topic.validates_each(:title, :content, [:title, :content]) do |record, attr|
      if perform
        record.errors.add attr, N_('gotcha')
        hits += 1
      end
    end

    GetText.set_locale_all "ja_JP.UTF-8"    
    t = Topic.new("title" => "valid", "content" => "whatever")
    assert !t.save
    assert_equal 4, hits
    assert_equal ["タイトル ごっちゃ", "タイトル ごっちゃ", 
      "内容 ごっちゃ", "内容 ごっちゃ"], t.errors.full_messages
    assert_equal ["ごっちゃ", "ごっちゃ"], t.errors.on(:title)
    assert_equal ["ごっちゃ", "ごっちゃ"], t.errors.on(:content)

    GetText.set_locale_all "en"    
    hits = 0
    t = Topic.new("title" => "valid", "content" => "whatever")
    assert !t.save
    assert_equal 4, hits
    assert_equal ["Title gotcha", "Title gotcha", 
      "Content gotcha", "Content gotcha"], t.errors.full_messages

    assert_equal ["gotcha", "gotcha"], t.errors.on(:title)
    assert_equal ["gotcha", "gotcha"], t.errors.on(:content)

  ensure
    perform = false
  end

=begin 
  #Don't need this
  def test_no_title_confirmation
  end
  def test_title_confirmation
  end
  def test_terms_of_service_agreement_no_acceptance
  end
=end

  def test_errors_on_boundary_breaking
    GetText.set_locale_all "ja_JP.UTF-8"  
    developer = Developer.new("name" => "xs")
    assert !developer.save
    assert_equal "開発者名は3文字以上で入力してください。", developer.errors.full_messages[0]
    assert_equal "開発者名は3文字以上で入力してください。", developer.errors.on("name")

    developer.name = "All too very long for this boundary, it really is"
    assert !developer.save
    assert_equal "開発者名は20文字以内で入力してください。", developer.errors.full_messages[0]
    assert_equal "開発者名は20文字以内で入力してください。", developer.errors.on("name")

    developer.name = "ちょうどぴったり12"
    assert developer.save

    GetText.set_locale_all "en"   
    developer = Developer.new("name" => "xs")
    assert !developer.save
    assert_equal "Name is too short (minimum is 3 characters)", developer.errors.full_messages[0]
    assert_equal "Name is too short (minimum is 3 characters)", developer.errors.on("name")

    developer.name = "All too very long for this boundary, it really is"
    assert !developer.save
    assert_equal "Name is too long (maximum is 20 characters)", developer.errors.full_messages[0]
    assert_equal "Name is too long (maximum is 20 characters)", developer.errors.on("name")

    developer.name = "Just right"
    assert developer.save
  end

  def test_terms_of_service_agreement
    GetText.set_locale_all "ja_JP.UTF-8"   
    Topic.validates_acceptance_of(:terms_of_service, :on => :create)
    t = Topic.create("title" => "We should be confirmed","terms_of_service" => "")
    assert !t.save
    assert_equal "利用規約を受諾してください。", t.errors.full_messages[0]
    assert_equal "利用規約を受諾してください。", t.errors.on(:terms_of_service)

    t.terms_of_service = "1"
    assert t.save

    GetText.set_locale_all "en"   
    t = Topic.create("title" => "We should be confirmed","terms_of_service" => "")
    assert !t.save
    assert_equal "Terms of service must be accepted", t.errors.full_messages[0]
    assert_equal "Terms of service must be accepted", t.errors.on(:terms_of_service)

    t.terms_of_service = "1"
    assert t.save
  end

  def test_eula_fn
    GetText.set_locale_all "ja_JP.UTF-8"  
    Topic.validates_acceptance_of(:eula, :message => N_("%{fn} must be abided"), :on => :create)

    t = Topic.create("title" => "We should be confirmed","eula" => "")
    assert !t.save
    assert_equal "Eulaに従ってください。", t.errors.full_messages[0]
    assert_equal "Eulaに従ってください。", t.errors.on(:eula)

    t.eula = "1"
    assert t.save

    GetText.set_locale_all "en"  
    t = Topic.create("title" => "We should be confirmed","eula" => "")
    assert !t.save
    assert_equal "Eula must be abided", t.errors.full_messages[0]
    assert_equal "Eula must be abided", t.errors.on(:eula)

    t.eula = "1"
    assert t.save
  end

  def test_eula
    GetText.set_locale_all "ja_JP.UTF-8"  
    Topic.validates_acceptance_of(:eula, :message => N_("must be abided"), :on => :create)

    t = Topic.create("title" => "We should be confirmed","eula" => "")
    assert !t.save
    assert_equal "Eula に従ってください。", t.errors.full_messages[0]
    assert_equal "に従ってください。", t.errors.on(:eula)

    t.eula = "1"
    assert t.save

    GetText.set_locale_all "en"  
    t = Topic.create("title" => "We should be confirmed","eula" => "")
    assert !t.save
    assert_equal "Eula must be abided", t.errors.full_messages[0]
    assert_equal "must be abided", t.errors.on(:eula)

    t.eula = "1"
    assert t.save
  end

  def test_terms_of_service_agreement_with_accept_value
    Topic.validates_acceptance_of(:terms_of_service, :on => :create, :accept => "I agree.")

    GetText.set_locale_all "ja_JP.UTF-8"  
    t = Topic.create("title" => "We should be confirmed", "terms_of_service" => "")
    assert !t.save
    assert_equal "利用規約を受諾してください。", t.errors.full_messages[0]
    assert_equal "利用規約を受諾してください。", t.errors.on(:terms_of_service)

    t.terms_of_service = "I agree."
    assert t.save

    GetText.set_locale_all "en"  
    t = Topic.create("title" => "We should be confirmed", "terms_of_service" => "")
    assert !t.save
    assert_equal "Terms of service must be accepted", t.errors.full_messages[0]
    assert_equal "Terms of service must be accepted", t.errors.on(:terms_of_service)

    t.terms_of_service = "I agree."
    assert t.save
  end

=begin
  #Don't need this
  def test_validates_acceptance_of_as_database_column
  end
  def test_validates_acceptance_of_with_non_existant_table
  end
=end

  def test_validate_presences
    Topic.validates_presence_of(:title, :content)

    GetText.set_locale_all "ja_JP.UTF-8" 
    t = Topic.create
    assert !t.save
    assert_equal "タイトルを入力してください。", t.errors.full_messages[0]
    assert_equal "内容を入力してください。", t.errors.full_messages[1]
    assert_equal "タイトルを入力してください。", t.errors.on(:title)
    assert_equal "内容を入力してください。", t.errors.on(:content)

    t.title = "something"
    t.content  = "   "

    assert !t.save
    assert_equal "内容を入力してください。", t.errors.full_messages[0]
    assert_equal "内容を入力してください。", t.errors.on(:content)

    t.content = "like stuff"

    assert t.save

    GetText.set_locale_all "en"  
    t = Topic.create
    assert !t.save
    assert_equal "Title can't be blank", t.errors.full_messages[0]
    assert_equal "Content can't be blank", t.errors.full_messages[1]
    assert_equal "Title can't be blank", t.errors.on(:title)
    assert_equal "Content can't be blank", t.errors.on(:content)

    t.title = "something"
    t.content  = "   "

    assert !t.save
    assert_equal "Content can't be blank", t.errors.full_messages[0]
    assert_equal "Content can't be blank", t.errors.on(:content)

    t.content = "like stuff"

    assert t.save
  end

  def test_validate_uniqueness
    Topic.validates_uniqueness_of(:title)

    GetText.set_locale_all "ja_JP.UTF-8"  
    t = Topic.new("title" => "I'm unique!")
    assert t.save, "Should save t as unique"

    t.content = "Remaining unique"
    assert t.save, "Should still save t as unique"

    t2 = Topic.new("title" => "I'm unique!")
    assert !t2.valid?, "Shouldn't be valid"
    assert !t2.save, "Shouldn't save t2 as unique"
    assert_equal "タイトルはすでに存在します。", t2.errors.full_messages[0]
    assert_equal "タイトルはすでに存在します。", t2.errors.on(:title)

    GetText.set_locale_all "en"  
    t = Topic.new("title" => "I'm unique2!")
    assert t.save, "Should save t as unique"

    t.content = "Remaining unique2"
    assert t.save, "Should still save t as unique"

    t2 = Topic.new("title" => "I'm unique2!")
    assert !t2.valid?, "Shouldn't be valid"
    assert !t2.save, "Shouldn't save t2 as unique"
    assert_equal "Title has already been taken", t2.errors.full_messages[0]
    assert_equal "Title has already been taken", t2.errors.on(:title)
  end

=begin
  #Don't need this
  def test_validate_uniqueness_with_scope
  end
  def test_validate_uniqueness_scoped_to_defining_class
  end
  def test_validate_uniqueness_with_scope_array
  end
  def test_validate_case_insensitive_uniqueness
  end
  def test_validate_case_sensitive_uniqueness
  end
=end

   def test_validate_straight_inheritance_uniqueness
    GetText.set_locale_all "ja_JP.UTF-8"  
    w1 = IneptWizard.create(:name => "I18nRincewind", :city => "I18nAnkh-Morpork")
    assert w1.valid?, "Saving w1"

    # Should use validation from base class (which is abstract)
    w2 = IneptWizard.new(:name => "I18nRincewind", :city => "I18nQuirm")
    assert !w2.valid?, "w2 shouldn't be valid"
    assert w2.errors.on(:name), "Should have errors for name"
    assert_equal "不器用な魔術師名はすでに存在します。", w2.errors.on(:name), "Should have uniqueness message for name"

    w3 = Conjurer.new(:name => "I18nRincewind", :city => "I18nQuirm")
    assert !w3.valid?, "w3 shouldn't be valid"
    assert w3.errors.on(:name), "Should have errors for name"
    assert_equal "手品師名はすでに存在します。", w3.errors.on(:name), "Should have uniqueness message for name"

    w4 = Conjurer.create(:name => "I18nThe Amazing Bonko", :city => "I18nQuirm")
    assert w4.valid?, "Saving w4"

    w5 = Thaumaturgist.new(:name => "I18nThe Amazing Bonko", :city => "I18nLancre")
    assert !w5.valid?, "w5 shouldn't be valid"
    assert w5.errors.on(:name), "Should have errors for name"
    assert_equal "奇術師名はすでに存在します。", w5.errors.on(:name), "Should have uniqueness message for name"

    w6 = Thaumaturgist.new(:name => "I18nMustrum Ridcully", :city => "I18nQuirm")
    assert !w6.valid?, "w6 shouldn't be valid"
    assert w6.errors.on(:city), "Should have errors for city"
    assert_equal "奇術師町はすでに存在します。", w6.errors.on(:city), "Should have uniqueness message for city"

    GetText.set_locale_all "en"  
    w1 = IneptWizard.create(:name => "Rincewind", :city => "Ankh-Morpork")
    assert w1.valid?, "Saving w1"

    # Should use validation from base class (which is abstract)
    w2 = IneptWizard.new(:name => "Rincewind", :city => "Quirm")
    assert !w2.valid?, "w2 shouldn't be valid"
    assert w2.errors.on(:name), "Should have errors for name"
    assert_equal "Name has already been taken", w2.errors.on(:name), "Should have uniqueness message for name"

    w3 = Conjurer.new(:name => "Rincewind", :city => "Quirm")
    assert !w3.valid?, "w3 shouldn't be valid"
    assert w3.errors.on(:name), "Should have errors for name"
    assert_equal "Name has already been taken", w3.errors.on(:name), "Should have uniqueness message for name"

    w4 = Conjurer.create(:name => "The Amazing Bonko", :city => "Quirm")
    assert w4.valid?, "Saving w4"

    w5 = Thaumaturgist.new(:name => "The Amazing Bonko", :city => "Lancre")
    assert !w5.valid?, "w5 shouldn't be valid"
    assert w5.errors.on(:name), "Should have errors for name"
    assert_equal "Name has already been taken", w5.errors.on(:name), "Should have uniqueness message for name"

    w6 = Thaumaturgist.new(:name => "Mustrum Ridcully", :city => "Quirm")
    assert !w6.valid?, "w6 shouldn't be valid"
    assert w6.errors.on(:city), "Should have errors for city"
    assert_equal "City has already been taken", w6.errors.on(:city), "Should have uniqueness message for city"
   end


   def test_validate_format_fn
    Topic.validates_format_of(:title, :content, :with => /^Validation\smacros \w+!$/, :message => N_("%{fn} is bad data"))

    GetText.set_locale_all "ja_JP.UTF-8"  
    t = Topic.create("title" => "i'm incorrect", "content" => "Validation macros rule!")
    assert !t.valid?, "Shouldn't be valid"
    assert !t.save, "Shouldn't save because it's invalid"
    assert_equal "タイトルは悪いデータです。", t.errors.full_messages[0]
    assert_equal "タイトルは悪いデータです。", t.errors.on(:title)
    assert_nil t.errors.on(:content)

    GetText.set_locale_all "en"  
    assert_raise(ArgumentError) { Topic.validates_format_of(:title, :content) }
    t = Topic.create("title" => "i'm incorrect", "content" => "Validation macros rule!")
    assert !t.valid?, "Shouldn't be valid"
    assert !t.save, "Shouldn't save because it's invalid"
    assert_equal "Title is bad data", t.errors.full_messages[0]
    assert_equal "Title is bad data", t.errors.on(:title)
    assert_nil t.errors.on(:content)
  end

  def test_validate_format
    Topic.validates_format_of(:title, :content, :with => /^Validation\smacros \w+!$/, :message => N_("is bad data"))

    GetText.set_locale_all "ja_JP.UTF-8"  
    t = Topic.create("title" => "i'm incorrect", "content" => "Validation macros rule!")
    assert !t.valid?, "Shouldn't be valid"
    assert !t.save, "Shouldn't save because it's invalid"
    assert_equal "タイトル は悪いデータです。", t.errors.full_messages[0]
    assert_equal "は悪いデータです。", t.errors.on(:title)
    assert_nil t.errors.on(:content)

    GetText.set_locale_all "en"  
    assert_raise(ArgumentError) { Topic.validates_format_of(:title, :content) }
    t = Topic.create("title" => "i'm incorrect", "content" => "Validation macros rule!")
    assert !t.valid?, "Shouldn't be valid"
    assert !t.save, "Shouldn't save because it's invalid"
    assert_equal "Title is bad data", t.errors.full_messages[0]
    assert_equal "is bad data", t.errors.on(:title)
    assert_nil t.errors.on(:content)

    t.title = "Validation macros rule!"

    assert t.save
    assert_nil t.errors.on(:title)

    assert_raise(ArgumentError) { Topic.validates_format_of(:title, :content) }
  end

=begin
  # Don't need this
  def test_validate_format_with_allow_blank
  end
=end
  def test_validate_format_numeric_fn
    Topic.validates_format_of(:title, :content, :with => /^[1-9][0-9]*$/, :message => N_("%{fn} is bad data"))

    GetText.set_locale_all "ja_JP.UTF-8"
    t = Topic.create("title" => "72x", "content" => "6789")
    assert !t.valid?, "Shouldn't be valid"
    assert !t.save, "Shouldn't save because it's invalid"
    assert_equal "タイトルは悪いデータです。", t.errors.on(:title)
    assert_nil t.errors.on(:content)
    
    t.title = "-11"
    assert !t.valid?, "Shouldn't be valid"

    t.title = "03"
    assert !t.valid?, "Shouldn't be valid"

    t.title = "z44"
    assert !t.valid?, "Shouldn't be valid"

    t.title = "5v7"
    assert !t.valid?, "Shouldn't be valid"

    t.title = "1"

    assert t.save
    assert_nil t.errors.on(:title)

    GetText.set_locale_all "en"
    t = Topic.create("title" => "72x", "content" => "6789")
    assert !t.valid?, "Shouldn't be valid"
    assert !t.save, "Shouldn't save because it's invalid"
    assert_equal "Title is bad data", t.errors.on(:title)
    assert_nil t.errors.on(:content)

    t.title = "-11"
    assert !t.valid?, "Shouldn't be valid"

    t.title = "03"
    assert !t.valid?, "Shouldn't be valid"

    t.title = "z44"
    assert !t.valid?, "Shouldn't be valid"

    t.title = "5v7"
    assert !t.valid?, "Shouldn't be valid"

    t.title = "1"

    assert t.save
    assert_nil t.errors.on(:title)
  end

  def test_validate_format_numeric
    Topic.validates_format_of(:title, :content, :with => /^[1-9][0-9]*$/, :message => N_("is bad data"))

    GetText.set_locale_all "ja_JP.UTF-8"
    t = Topic.create("title" => "72x", "content" => "6789")
    assert !t.valid?, "Shouldn't be valid"
    assert !t.save, "Shouldn't save because it's invalid"
    assert_equal "は悪いデータです。", t.errors.on(:title)
    assert_nil t.errors.on(:content)
    
    t.title = "-11"
    assert !t.valid?, "Shouldn't be valid"

    t.title = "03"
    assert !t.valid?, "Shouldn't be valid"

    t.title = "z44"
    assert !t.valid?, "Shouldn't be valid"

    t.title = "5v7"
    assert !t.valid?, "Shouldn't be valid"

    t.title = "1"

    assert t.save
    assert_nil t.errors.on(:title)

    GetText.set_locale_all "en"
    t = Topic.create("title" => "72x", "content" => "6789")
    assert !t.valid?, "Shouldn't be valid"
    assert !t.save, "Shouldn't save because it's invalid"
    assert_equal "is bad data", t.errors.on(:title)
    assert_nil t.errors.on(:content)

    t.title = "-11"
    assert !t.valid?, "Shouldn't be valid"

    t.title = "03"
    assert !t.valid?, "Shouldn't be valid"

    t.title = "z44"
    assert !t.valid?, "Shouldn't be valid"

    t.title = "5v7"
    assert !t.valid?, "Shouldn't be valid"

    t.title = "1"

    assert t.save
    assert_nil t.errors.on(:title)
  end

  def test_validate_format_with_formatted_message_fn
    Topic.validates_format_of(:title, :with => /^Valid Title$/, :message => N_("%{fn} can not be %{val}"))

    GetText.set_locale_all "ja_JP.UTF-8"
    t = Topic.create(:title => 'Invalid title')
    assert_equal "Invalid titleはタイトルではありません。", t.errors.full_messages[0]
    assert_equal "Invalid titleはタイトルではありません。", t.errors.on(:title)

    GetText.set_locale_all "en"
    t = Topic.create(:title => 'Invalid title')
    assert_equal "Title can not be Invalid title", t.errors.full_messages[0]
    assert_equal "Title can not be Invalid title", t.errors.on(:title)
  end
 
  def test_validate_format_with_formatted_message
    Topic.validates_format_of(:title, :with => /^Valid Title$/, :message => N_("can not be %{val}"))

    GetText.set_locale_all "ja_JP.UTF-8"
    t = Topic.create(:title => 'Invalid title')
    assert_equal "タイトル はInvalid titleではありません。", t.errors.full_messages[0]
    assert_equal "はInvalid titleではありません。", t.errors.on(:title)

    GetText.set_locale_all "en"
    t = Topic.create(:title => 'Invalid title')
    assert_equal "Title can not be Invalid title", t.errors.full_messages[0]
    assert_equal "can not be Invalid title", t.errors.on(:title)
  end

  def test_validates_inclusion_of
    Topic.validates_inclusion_of( :title, :in => %w( a b c d e f g ) )

    GetText.set_locale_all "ja_JP.UTF-8"  
    t = Topic.create("title" => "a", "content" => "I know you are but what am I?")
    assert t.valid?
    t.title = "uhoh"
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "タイトルは一覧にありません。", t.errors.full_messages[0]
    assert_equal "タイトルは一覧にありません。", t.errors.on(:title)

    GetText.set_locale_all "en"  
    t = Topic.create("title" => "a", "content" => "I know you are but what am I?")
    assert t.valid?
    t.title = "uhoh"
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title is not included in the list", t.errors.full_messages[0]
    assert_equal "Title is not included in the list", t.errors.on(:title)
  end

=begin
  # Don't need this
  def test_validates_inclusion_of_with_allow_nil
  end
  def test_numericality_with_getter_method
  end
  def test_validates_length_of_with_allow_nil
  end
  def test_validates_length_of_with_allow_blank
  end
=end

  def test_validates_inclusion_of_with_formatted_message_fn
    Topic.validates_inclusion_of( :title, :in => %w( a b c d e f g ), :message => N_("%{fn} option %{val} is not in the list") )
    GetText.set_locale_all "ja_JP.UTF-8"

    assert Topic.create("title" => "a", "content" => "abc").valid?

    t = Topic.create("title" => "uhoh", "content" => "abc")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "オプションuhohはタイトル一覧にありません。", t.errors.full_messages[0]
    assert_equal "オプションuhohはタイトル一覧にありません。", t.errors["title"]

    GetText.set_locale_all "en"
    assert Topic.create("title" => "a", "content" => "abc").valid?

    t = Topic.create("title" => "uhoh", "content" => "abc")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title option uhoh is not in the list", t.errors.full_messages[0]
    assert_equal "Title option uhoh is not in the list", t.errors["title"]
  end

  def test_validates_inclusion_of_with_formatted_message
    Topic.validates_inclusion_of( :title, :in => %w( a b c d e f g ), :message => N_("option %{val} is not in the list") )
    GetText.set_locale_all "ja_JP.UTF-8"

    assert Topic.create("title" => "a", "content" => "abc").valid?

    t = Topic.create("title" => "uhoh", "content" => "abc")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "タイトル オプションuhohは一覧にありません。", t.errors.full_messages[0]
    assert_equal "オプションuhohは一覧にありません。", t.errors["title"]

    GetText.set_locale_all "en"
    assert Topic.create("title" => "a", "content" => "abc").valid?

    t = Topic.create("title" => "uhoh", "content" => "abc")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title option uhoh is not in the list", t.errors.full_messages[0]
    assert_equal "option uhoh is not in the list", t.errors["title"]
  end

=begin
  Don't need this
  def test_numericality_with_allow_nil_and_getter_method
  end
  def test_validates_exclusion_of
  end
=end
  def test_validates_exclusion_of_with_formatted_message_fn
    GetText.set_locale_all "ja_JP.UTF-8"
    Topic.validates_exclusion_of( :title, :in => %w( abe monkey ), :message => N_("%{fn} option %{val} is restricted") )

    assert Topic.create("title" => "something", "content" => "abc")

    t = Topic.create("title" => "monkey")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "オプションタイトルmonkeyは制限されています。", t.errors.full_messages[0]
    assert_equal "オプションタイトルmonkeyは制限されています。", t.errors["title"]

    GetText.set_locale_all "en"
    assert Topic.create("title" => "something", "content" => "abc")

    t = Topic.create("title" => "monkey")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title option monkey is restricted", t.errors.full_messages[0]
    assert_equal "Title option monkey is restricted", t.errors["title"]
  end

  def test_validates_exclusion_of_with_formatted_message
    GetText.set_locale_all "ja_JP.UTF-8"
    Topic.validates_exclusion_of( :title, :in => %w( abe monkey ), :message => N_("option %{val} is restricted") )

    assert Topic.create("title" => "something", "content" => "abc")

    t = Topic.create("title" => "monkey")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "タイトル オプションmonkeyは制限されています。", t.errors.full_messages[0]
    assert_equal "オプションmonkeyは制限されています。", t.errors["title"]

    GetText.set_locale_all "en"
    assert Topic.create("title" => "something", "content" => "abc")

    t = Topic.create("title" => "monkey")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title option monkey is restricted", t.errors.full_messages[0]
    assert_equal "option monkey is restricted", t.errors["title"]
  end

  def test_validates_length_of_using_minimum
    Topic.validates_length_of :title, :minimum => 5

    GetText.set_locale_all "ja_JP.UTF-8"  
    t = Topic.create("title" => "valid", "content" => "whatever")
    assert t.valid?

    t.title = "not"
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "タイトルは5文字以上で入力してください。", t.errors.full_messages[0]
    assert_equal "タイトルは5文字以上で入力してください。", t.errors.on("title")

    GetText.set_locale_all "en"  
    t = Topic.create("title" => "valid", "content" => "whatever")
    assert t.valid?

    t.title = "not"
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title is too short (minimum is 5 characters)", t.errors.full_messages[0]
    assert_equal "Title is too short (minimum is 5 characters)", t.errors.on("title")
  end

  def test_validates_length_of_using_maximum
    Topic.validates_length_of :title, :maximum => 5
    GetText.set_locale_all "ja_JP.UTF-8"  
    t = Topic.create("title" => "valid", "content" => "whatever")
    assert t.valid?

    t.title = "notvalid"
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "タイトルは5文字以内で入力してください。", t.errors.full_messages[0]
    assert_equal "タイトルは5文字以内で入力してください。", t.errors.on("title")

    GetText.set_locale_all "en"  
    t = Topic.create("title" => "valid", "content" => "whatever")
    assert t.valid?

    t.title = "notvalid"
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title is too long (maximum is 5 characters)", t.errors.full_messages[0]
    assert_equal "Title is too long (maximum is 5 characters)", t.errors.on("title")
  end

=begin
# Don't need this
  def test_optionally_validates_length_of_using_minimum
  end
=end

  def test_validates_length_of_using_within
    Topic.validates_length_of(:title, :content, :within => 3..5)

    GetText.set_locale_all "ja_JP.UTF-8"
    t = Topic.new("title" => "a!", "content" => "I'm ooooooooh so very long")
    assert !t.valid?
    assert_equal "タイトルは3文字以上で入力してください。", t.errors.full_messages[0]
    assert_equal "内容は5文字以内で入力してください。", t.errors.full_messages[1]
    assert_equal "タイトルは3文字以上で入力してください。", t.errors.on(:title)
    assert_equal "内容は5文字以内で入力してください。", t.errors.on(:content)

    t.title = nil
    t.content = nil
    assert !t.valid?
    assert_equal "タイトルは3文字以上で入力してください。", t.errors.full_messages[0]
    assert_equal "内容は3文字以上で入力してください。", t.errors.full_messages[1]
    assert_equal "タイトルは3文字以上で入力してください。", t.errors.on(:title)
    assert_equal "内容は3文字以上で入力してください。", t.errors.on(:content)

    GetText.set_locale_all "en"  
    t = Topic.new("title" => "a!", "content" => "I'm ooooooooh so very long")
    assert !t.valid?
    assert_equal "Title is too short (minimum is 3 characters)", t.errors.full_messages[0]
    assert_equal "Content is too long (maximum is 5 characters)", t.errors.full_messages[1]
    assert_equal "Title is too short (minimum is 3 characters)", t.errors.on(:title)
    assert_equal "Content is too long (maximum is 5 characters)", t.errors.on(:content)

    t.title = nil
    t.content = nil
    assert !t.valid?
    assert_equal "Title is too short (minimum is 3 characters)", t.errors.full_messages[0]
    assert_equal "Content is too short (minimum is 3 characters)", t.errors.full_messages[1]
    assert_equal "Title is too short (minimum is 3 characters)", t.errors.on(:title)
    assert_equal "Content is too short (minimum is 3 characters)", t.errors.on(:content)
  end

=begin
# Don't need this
  def test_optionally_validates_length_of_using_within
  end
=end

  def test_optionally_validates_length_of_using_within_on_create_fn
    Topic.validates_length_of :title, :content, :within => 5..10, :on => :create, :too_short => N_("my string(%{fn}) is too short: %d"), :too_long => N_("my string(%{fn}) is too long: %d")

    GetText.set_locale_all "ja_JP.UTF-8"  
    t = Topic.create("title" => "thisisnotvalid", "content" => "whatever")
    assert !t.save
    assert t.errors.on(:title)
    assert_equal "文字列:タイトルは長すぎ: 10", t.errors.full_messages[0]
    assert_equal "文字列:タイトルは長すぎ: 10", t.errors.on(:title)

    GetText.set_locale_all "en"  
    t = Topic.create("title" => "thisisnotvalid", "content" => "whatever")
    assert !t.save
    assert t.errors.on(:title)
    assert_equal "my string(Title) is too long: 10", t.errors.full_messages[0]
    assert_equal "my string(Title) is too long: 10", t.errors.on(:title)
  end

  def test_optionally_validates_length_of_using_within_on_create
    Topic.validates_length_of :title, :content, :within => 5..10, :on => :create, :too_short => N_("my string is too short: %d"), :too_long => N_("my string is too long: %d")

    GetText.set_locale_all "ja_JP.UTF-8"  
    t = Topic.create("title" => "thisisnotvalid", "content" => "whatever")
    assert !t.save
    assert t.errors.on(:title)
    assert_equal "タイトル 文字列は長すぎ: 10", t.errors.full_messages[0]
    assert_equal "文字列は長すぎ: 10", t.errors.on(:title)

    GetText.set_locale_all "en"  
    t = Topic.create("title" => "thisisnotvalid", "content" => "whatever")
    assert !t.save
    assert t.errors.on(:title)
    assert_equal "Title my string is too long: 10", t.errors.full_messages[0]
    assert_equal "my string is too long: 10", t.errors.on(:title)
  end

  def test_optionally_validates_length_of_using_within_on_update_fn
    Topic.validates_length_of :title, :content, :within => 5..10, :on => :update, :too_short => N_("my string(%{fn}) is too short: %d"), :too_long => N_("my string(%{fn}) is too long: %d")
    GetText.set_locale_all "ja_JP.UTF-8"  
    t = Topic.create("title" => "vali", "content" => "whatever")
    assert !t.save
    assert t.errors.on(:title)

    t.title = "not"
    assert !t.save
    assert t.errors.on(:title)
    assert_equal "文字列:タイトルは短すぎ: 5", t.errors.full_messages[0]
    assert_equal "文字列:タイトルは短すぎ: 5", t.errors.on(:title)

    GetText.set_locale_all "en"  
    t = Topic.create("title" => "vali", "content" => "whatever")
    assert !t.save
    assert t.errors.on(:title)

    t.title = "not"
    assert !t.save
    assert t.errors.on(:title)
    assert_equal "my string(Title) is too short: 5", t.errors.full_messages[0]
    assert_equal "my string(Title) is too short: 5", t.errors.on(:title)

  end

  def test_optionally_validates_length_of_using_within_on_update
    Topic.validates_length_of :title, :content, :within => 5..10, :on => :update, :too_short => N_("my string is too short: %d"), :too_long => N_("my string is too long: %d")
    GetText.set_locale_all "ja_JP.UTF-8"  
    t = Topic.create("title" => "vali", "content" => "whatever")
    assert !t.save
    assert t.errors.on(:title)

    t.title = "not"
    assert !t.save
    assert t.errors.on(:title)
    assert_equal "タイトル 文字列は短すぎ: 5", t.errors.full_messages[0]
    assert_equal "文字列は短すぎ: 5", t.errors.on(:title)

    GetText.set_locale_all "en"  
    t = Topic.create("title" => "vali", "content" => "whatever")
    assert !t.save
    assert t.errors.on(:title)

    t.title = "not"
    assert !t.save
    assert t.errors.on(:title)
    assert_equal "Title my string is too short: 5", t.errors.full_messages[0]
    assert_equal "my string is too short: 5", t.errors.on(:title)

  end

  def test_validates_length_of_using_is
    Topic.validates_length_of :title, :is => 5

    GetText.set_locale_all "ja_JP.UTF-8"
    t = Topic.create("title" => "valid", "content" => "whatever")
    assert t.valid?

    t.title = "notvalid"
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "タイトルは5文字で入力してください。", t.errors.full_messages[0]
    assert_equal "タイトルは5文字で入力してください。", t.errors.on("title")

    GetText.set_locale_all "en"
    t = Topic.create("title" => "valid", "content" => "whatever")
    assert t.valid?

    t.title = "notvalid"
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title is the wrong length (should be 5 characters)", t.errors.full_messages[0]
    assert_equal "Title is the wrong length (should be 5 characters)", t.errors.on("title")

  end

=begin
  # Don't need this
  def test_optionally_validates_length_of_using_is
  end
  def test_validates_length_of_using_bignum
  end
=end

  def test_validates_length_with_globaly_modified_error_message_fn
    ActiveRecord::Errors.default_error_messages[:too_short] = N_('%{fn} %d dayo')
    Topic.validates_length_of :title, :minimum => 10

    GetText.set_locale_all "ja_JP.UTF-8"
    t = Topic.create(:title => 'too short')
    assert !t.valid?
    assert_equal 'タイトルは10以上だよ。', t.errors.full_messages[0]
    assert_equal 'タイトルは10以上だよ。', t.errors.on('title')

    GetText.set_locale_all "en"
    t = Topic.create(:title => 'too short')
    assert !t.valid?
    assert_equal 'Title 10 dayo', t.errors.full_messages[0]
    assert_equal 'Title 10 dayo', t.errors.on('title')
  end

  def test_validates_length_with_globaly_modified_error_message
    ActiveRecord::Errors.default_error_messages[:too_short] = N_('%d dayo')
    Topic.validates_length_of :title, :minimum => 10

    GetText.set_locale_all "ja_JP.UTF-8"
    t = Topic.create(:title => 'too short')
    assert !t.valid?
    assert_equal 'タイトル は10以上だよ。', t.errors.full_messages[0]
    assert_equal 'は10以上だよ。', t.errors.on('title')

    GetText.set_locale_all "en"
    t = Topic.create(:title => 'too short')
    assert !t.valid?
    assert_equal 'Title 10 dayo', t.errors.full_messages[0]
    assert_equal '10 dayo', t.errors.on('title')
  end

=begin
  def test_validates_size_of_association
  end
  def test_validates_size_of_association_using_within
  end
  def test_validates_length_of_nasty_params
  end
=end

  def test_validates_length_of_custom_errors_for_minimum_with_message_fn
    Topic.validates_length_of( :title, :minimum => 5, :message => N_("%{fn} hoo %d") )
    GetText.set_locale_all "ja_JP.UTF-8"
    t = Topic.create("title" => "uhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "タイトルふー5", t.errors.full_messages[0]
    assert_equal "タイトルふー5", t.errors.on("title")

    GetText.set_locale_all "en"
    t = Topic.create("title" => "uhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title hoo 5", t.errors.full_messages[0]
    assert_equal "Title hoo 5", t.errors.on("title")
  end

  def test_validates_length_of_custom_errors_for_minimum_with_message
    Topic.validates_length_of( :title, :minimum => 5, :message => N_("hoo %d") )
    GetText.set_locale_all "ja_JP.UTF-8"
    t = Topic.create("title" => "uhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "タイトル ふー5", t.errors.full_messages[0]
    assert_equal "ふー5", t.errors.on("title")

    GetText.set_locale_all "en"
    t = Topic.create("title" => "uhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title hoo 5", t.errors.full_messages[0]
    assert_equal "hoo 5", t.errors.on("title")
  end

  def test_validates_length_of_custom_errors_for_minimum_with_too_short_fn
    Topic.validates_length_of( :title, :minimum=>5, :too_short => N_("%{fn} hoo %d") )

    GetText.set_locale_all "ja_JP.UTF-8"
    t = Topic.create("title" => "uhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "タイトルふー5", t.errors.full_messages[0]
    assert_equal "タイトルふー5", t.errors.on("title")

    GetText.set_locale_all "en"
    t = Topic.create("title" => "uhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title hoo 5", t.errors.full_messages[0]
    assert_equal "Title hoo 5", t.errors.on("title")
  end

  def test_validates_length_of_custom_errors_for_minimum_with_too_short
    Topic.validates_length_of( :title, :minimum=>5, :too_short => N_("hoo %d") )

    GetText.set_locale_all "ja_JP.UTF-8"
    t = Topic.create("title" => "uhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "タイトル ふー5", t.errors.full_messages[0]
    assert_equal "ふー5", t.errors.on("title")

    GetText.set_locale_all "en"
    t = Topic.create("title" => "uhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title hoo 5", t.errors.full_messages[0]
    assert_equal "hoo 5", t.errors.on("title")
  end

  def test_validates_length_of_custom_errors_for_maximum_with_message_fn
    Topic.validates_length_of( :title, :maximum=>5, :message => N_("%{fn} hoo %d"))

    GetText.set_locale_all "ja_JP.UTF-8"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "タイトルふー5", t.errors.full_messages[0]
    assert_equal "タイトルふー5", t.errors.on("title")

    GetText.set_locale_all "en"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title hoo 5", t.errors.full_messages[0]
    assert_equal "Title hoo 5", t.errors.on("title")
  end

  def test_validates_length_of_custom_errors_for_maximum_with_message
    Topic.validates_length_of( :title, :maximum=>5, :message => N_("hoo %d"))

    GetText.set_locale_all "ja_JP.UTF-8"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "タイトル ふー5", t.errors.full_messages[0]
    assert_equal "ふー5", t.errors.on("title")

    GetText.set_locale_all "en"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title hoo 5", t.errors.full_messages[0]
    assert_equal "hoo 5", t.errors.on("title")
  end
  def test_validates_length_of_custom_errors_for_maximum_with_too_long_fn
    Topic.validates_length_of( :title, :maximum=>5, :too_long => N_("%{fn} hoo %d"))

    GetText.set_locale_all "ja_JP.UTF-8"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "タイトルふー5", t.errors.full_messages[0]
    assert_equal "タイトルふー5", t.errors.on("title")

    GetText.set_locale_all "en"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title hoo 5", t.errors.full_messages[0]
    assert_equal "Title hoo 5", t.errors.on("title")
  end

  def test_validates_length_of_custom_errors_for_maximum_with_too_long
    Topic.validates_length_of( :title, :maximum=>5, :too_long => N_("hoo %d"))

    GetText.set_locale_all "ja_JP.UTF-8"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "タイトル ふー5", t.errors.full_messages[0]
    assert_equal "ふー5", t.errors.on("title")

    GetText.set_locale_all "en"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title hoo 5", t.errors.full_messages[0]
    assert_equal "hoo 5", t.errors.on("title")
  end

  def test_validates_length_of_custom_errors_for_is_with_message_fn
    Topic.validates_length_of( :title, :is=>5, :message=> N_("%{fn} hoo %d") )
    GetText.set_locale_all "ja_JP.UTF-8"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "タイトルふー5", t.errors.full_messages[0]
    assert_equal "タイトルふー5", t.errors.on("title")

    GetText.set_locale_all "en"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title hoo 5", t.errors.full_messages[0]
    assert_equal "Title hoo 5", t.errors.on("title")
  end

  def test_validates_length_of_custom_errors_for_is_with_message
    Topic.validates_length_of( :title, :is=>5, :message=> N_("hoo %d") )
    GetText.set_locale_all "ja_JP.UTF-8"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "タイトル ふー5", t.errors.full_messages[0]
    assert_equal "ふー5", t.errors.on("title")

    GetText.set_locale_all "en"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title hoo 5", t.errors.full_messages[0]
    assert_equal "hoo 5", t.errors.on("title")
  end

  def test_validates_length_of_custom_errors_for_is_with_wrong_length_fn
    Topic.validates_length_of( :title, :is=>5, :wrong_length=> N_("hoo %d") )
    GetText.set_locale_all "ja_JP.UTF-8"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "タイトル ふー5", t.errors.full_messages[0]
    assert_equal "ふー5", t.errors.on("title")

    GetText.set_locale_all "en"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title hoo 5", t.errors.full_messages[0]
    assert_equal "hoo 5", t.errors.on("title")
  end

  def test_validates_length_of_custom_errors_for_is_with_wrong_length
    Topic.validates_length_of( :title, :is=>5, :wrong_length=> N_("hoo %d") )
    GetText.set_locale_all "ja_JP.UTF-8"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "タイトル ふー5", t.errors.full_messages[0]
    assert_equal "ふー5", t.errors.on("title")

    GetText.set_locale_all "en"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title hoo 5", t.errors.full_messages[0]
    assert_equal "hoo 5", t.errors.on("title")
  end

=begin
  def test_validates_length_of_using_minimum_utf8
  end
  def test_validates_length_of_using_maximum_utf8
  end
  def test_validates_length_of_using_within_utf8
  end
  def test_optionally_validates_length_of_using_within_utf8
  end
  def test_optionally_validates_length_of_using_within_on_create_utf8
  end
  def test_optionally_validates_length_of_using_within_on_update_utf8
  end
  def test_validates_length_of_using_is_utf8
  end
  def test_validates_size_of_association_utf8
  end
  def test_validates_associated_many
  end
  def test_validates_associated_one
  end
=end

  def test_validate_block_fn
    Topic.validate { |topic| topic.errors.add("title", N_("%{fn} will never be valid")) }
    GetText.set_locale_all "ja_JP.UTF-8"
    t = Topic.create("title" => "Title", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "タイトルは決して正しくならないでしょう。", t.errors.full_messages[0]
    assert_equal "タイトルは決して正しくならないでしょう。", t.errors.on("title")

    GetText.set_locale_all "en"
    t = Topic.create("title" => "Title", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title will never be valid", t.errors.full_messages[0]
    assert_equal "Title will never be valid", t.errors.on("title")
  end

  def test_validate_block
    Topic.validate { |topic| topic.errors.add("title", N_("will never be valid")) }
    GetText.set_locale_all "ja_JP.UTF-8"
    t = Topic.create("title" => "Title", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "タイトル は決して正しくならないでしょう。", t.errors.full_messages[0]
    assert_equal "は決して正しくならないでしょう。", t.errors.on("title")

    GetText.set_locale_all "en"
    t = Topic.create("title" => "Title", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title will never be valid", t.errors.full_messages[0]
    assert_equal "will never be valid", t.errors.on("title")
  end

=begin
  def test_invalid_validator
  end
  def test_throw_away_typing
  end
=end

  def test_validates_acceptance_of_with_custom_error_using_quotes_fn
    Developer.validates_acceptance_of :salary, :message=> N_("%{fn} contains 'single' and \"double\" quotes")
 
    GetText.set_locale_all "ja_JP.UTF-8"
    d = Developer.new
    d.salary = "0"
    assert !d.valid?
    if AR_6657
      assert_equal "給料は'シングル' \"ダブル\"クオートを含む。", d.errors.on(:salary).last
    else
      assert_equal "給料は'シングル' \"ダブル\"クオートを含む。", d.errors.on(:salary).first
    end
    GetText.set_locale_all "en"
    d = Developer.new
    d.salary = "0"
    assert !d.valid?
    if AR_6657
      assert_equal "Salary contains 'single' and \"double\" quotes", d.errors.on(:salary).last 
    else
      assert_equal "Salary contains 'single' and \"double\" quotes", d.errors.on(:salary).first 
    end
  end

  def test_validates_acceptance_of_with_custom_error_using_quotes
    Developer.validates_acceptance_of :salary, :message=> N_("This string contains 'single' and \"double\" quotes")
 
    GetText.set_locale_all "ja_JP.UTF-8"
    d = Developer.new
    d.salary = "0"
    assert !d.valid?
    if AR_6657
      assert_equal "この文字列は'シングル' \"ダブル\"クオートを含む。", d.errors.on(:salary).last
    else
      assert_equal "この文字列は'シングル' \"ダブル\"クオートを含む。", d.errors.on(:salary).first
    end
    GetText.set_locale_all "en"
    d = Developer.new
    d.salary = "0"
    assert !d.valid?
    if AR_6657
      assert_equal "This string contains 'single' and \"double\" quotes", d.errors.on(:salary).last 
    else
      assert_equal "This string contains 'single' and \"double\" quotes", d.errors.on(:salary).first
    end
  end

  def test_validates_confirmation_of_with_custom_error_using_quotes_fn
    Developer.validates_confirmation_of :name, :message=> N_("%{fn} contains 'single' and \"double\" quotes")

    GetText.set_locale_all "ja_JP.UTF-8"
    d = Developer.new
    d.name = "John"
    d.name_confirmation = "Johnny"
    assert !d.valid?
    if AR_6657
      assert_equal "開発者名は'シングル' \"ダブル\"クオートを含む。", d.errors.on(:name).last
    else
      assert_equal "開発者名は'シングル' \"ダブル\"クオートを含む。", d.errors.on(:name).first
    end
    GetText.set_locale_all "en"
    d = Developer.new
    d.name = "John"
    d.name_confirmation = "Johnny"
    assert !d.valid?
    if AR_6657
      assert_equal "Name contains 'single' and \"double\" quotes", d.errors.on(:name).last
    else
      assert_equal "Name contains 'single' and \"double\" quotes", d.errors.on(:name).first
    end
  end

  def test_validates_confirmation_of_with_custom_error_using_quotes
    Developer.validates_confirmation_of :name, :message=> N_("This string contains 'single' and \"double\" quotes")

    GetText.set_locale_all "ja_JP.UTF-8"
    d = Developer.new
    d.name = "John"
    d.name_confirmation = "Johnny"
    assert !d.valid?
    assert_equal "この文字列は'シングル' \"ダブル\"クオートを含む。", d.errors.on(:name)

    GetText.set_locale_all "en"
    d = Developer.new
    d.name = "John"
    d.name_confirmation = "Johnny"
    assert !d.valid?
    assert_equal "This string contains 'single' and \"double\" quotes", d.errors.on(:name)
  end

  def test_validates_format_of_with_custom_error_using_quotes_fn
    Developer.validates_format_of :name, :with => /^(A-Z*)$/, :message => "%{fn} contains 'single' and \"double\" quotes"

    GetText.set_locale_all "ja_JP.UTF-8"
    d = Developer.new
    d.name = "John 32"
    assert !d.valid?
    if AR_6657
      assert_equal "開発者名は'シングル' \"ダブル\"クオートを含む。", d.errors.on(:name).last
    else
      assert_equal "開発者名は'シングル' \"ダブル\"クオートを含む。", d.errors.on(:name).first
    end

    GetText.set_locale_all "en"
    d = Developer.new
    d.name = "John 32"
    assert !d.valid?
    if AR_6657
      assert_equal "Name contains 'single' and \"double\" quotes", d.errors.on(:name).last
    else
      assert_equal "Name contains 'single' and \"double\" quotes", d.errors.on(:name).first
    end
  end

  def test_validates_format_of_with_custom_error_using_quotes
    Developer.validates_format_of :name, :with => /^(A-Z*)$/, :message => "This string contains 'single' and \"double\" quotes"

    GetText.set_locale_all "ja_JP.UTF-8"
    d = Developer.new
    d.name = "John 32"
    assert !d.valid?
    assert_equal "この文字列は'シングル' \"ダブル\"クオートを含む。", d.errors.on(:name)

    GetText.set_locale_all "en"
    d = Developer.new
    d.name = "John 32"
    assert !d.valid?
    assert_equal "This string contains 'single' and \"double\" quotes", d.errors.on(:name)
  end

  def test_validates_inclusion_of_with_custom_error_using_quotes_fn
    Developer.validates_inclusion_of :salary, :in => 1000..80000, :message=> N_("%{fn} contains 'single' and \"double\" quotes")
 
    GetText.set_locale_all "ja_JP.UTF-8"
    d = Developer.new
    d.salary = "90,000"
    assert !d.valid?
    if AR_6657
      assert_equal "給料は'シングル' \"ダブル\"クオートを含む。", d.errors.on(:salary).last
    else
      assert_equal "給料は'シングル' \"ダブル\"クオートを含む。", d.errors.on(:salary).first
    end
    GetText.set_locale_all "en"
    d = Developer.new
    d.salary = "90,000"
    assert !d.valid?
    if AR_6657
      assert_equal "Salary contains 'single' and \"double\" quotes", d.errors.on(:salary).last
    else
      assert_equal "Salary contains 'single' and \"double\" quotes", d.errors.on(:salary).first
    end
  end

  def test_validates_inclusion_of_with_custom_error_using_quotes
    Developer.validates_inclusion_of :salary, :in => 1000..80000, :message=> N_("This string contains 'single' and \"double\" quotes")

    GetText.set_locale_all "ja_JP.UTF-8"
    d = Developer.new
    d.salary = "90,000"
    assert !d.valid?
    if AR_6657
      assert_equal "この文字列は'シングル' \"ダブル\"クオートを含む。", d.errors.on(:salary).last
    else
      assert_equal "この文字列は'シングル' \"ダブル\"クオートを含む。", d.errors.on(:salary).first
    end
    GetText.set_locale_all "en"
    d = Developer.new
    d.salary = "90,000"
    assert !d.valid?
    if AR_6657
      assert_equal "This string contains 'single' and \"double\" quotes", d.errors.on(:salary).last
    else
      assert_equal "This string contains 'single' and \"double\" quotes", d.errors.on(:salary).first
    end
  end

  def test_validates_length_of_with_custom_too_long_using_quotes_fn
    Developer.validates_length_of :name, :maximum => 4, :too_long=> N_("%{fn} contains 'single' and \"double\" quotes")

    GetText.set_locale_all "ja_JP.UTF-8"
    d = Developer.new
    d.name = "Jeffrey"
    assert !d.valid?
    if AR_6657
      assert_equal "開発者名は'シングル' \"ダブル\"クオートを含む。", d.errors.on(:name).last
    else
      assert_equal "開発者名は'シングル' \"ダブル\"クオートを含む。", d.errors.on(:name).first
    end
    GetText.set_locale_all "en"
    d = Developer.new
    d.name = "Jeffrey"
    assert !d.valid?
    if AR_6657
      assert_equal "Name contains 'single' and \"double\" quotes", d.errors.on(:name).last
    else
      assert_equal "Name contains 'single' and \"double\" quotes", d.errors.on(:name).first
    end
  end

  def test_validates_length_of_with_custom_too_long_using_quotes
    Developer.validates_length_of :name, :maximum => 4, :too_long=> N_("This string contains 'single' and \"double\" quotes")

    GetText.set_locale_all "ja_JP.UTF-8"
    d = Developer.new
    d.name = "Jeffrey"
    assert !d.valid?
    assert_equal "この文字列は'シングル' \"ダブル\"クオートを含む。", d.errors.on(:name).last

    GetText.set_locale_all "en"
    d = Developer.new
    d.name = "Jeffrey"
    assert !d.valid?
    assert_equal "This string contains 'single' and \"double\" quotes", d.errors.on(:name).last
  end

  def test_validates_length_of_with_custom_too_short_using_quotes_fn
    Developer.validates_length_of :name, :minimum => 4, :too_short=> N_("%{fn} contains 'single' and \"double\" quotes")
    GetText.set_locale_all "ja_JP.UTF-8"
    d = Developer.new
    d.name = "Joe"
    assert !d.valid?
    if AR_6657
      assert_equal "開発者名は'シングル' \"ダブル\"クオートを含む。", d.errors.on(:name).last
    else
      assert_equal "開発者名は'シングル' \"ダブル\"クオートを含む。", d.errors.on(:name).first
    end
    GetText.set_locale_all "en"
    d = Developer.new
    d.name = "Joe"
    assert !d.valid?
    if AR_6657
      assert_equal "Name contains 'single' and \"double\" quotes", d.errors.on(:name).last
    else
      assert_equal "Name contains 'single' and \"double\" quotes", d.errors.on(:name).first
    end
  end

  def test_validates_length_of_with_custom_too_short_using_quotes
    Developer.validates_length_of :name, :minimum => 4, :too_short=> N_("This string contains 'single' and \"double\" quotes")
    GetText.set_locale_all "ja_JP.UTF-8"
    d = Developer.new
    d.name = "Joe"
    assert !d.valid?
    assert_equal "この文字列は'シングル' \"ダブル\"クオートを含む。", d.errors.on(:name).last

    GetText.set_locale_all "en"
    d = Developer.new
    d.name = "Joe"
    assert !d.valid?
    assert_equal "This string contains 'single' and \"double\" quotes", d.errors.on(:name).last
  end

  def test_validates_length_of_with_custom_message_using_quotes_fn
    GetText.set_locale_all "ja_JP.UTF-8"
    Developer.validates_length_of :name, :minimum => 4, :message=> N_("%{fn} contains 'single' and \"double\" quotes")
    d = Developer.new
    d.name = "Joe"
    assert !d.valid?
    if AR_6657
      assert_equal "開発者名は'シングル' \"ダブル\"クオートを含む。", d.errors.on(:name).last
    else
      assert_equal "開発者名は'シングル' \"ダブル\"クオートを含む。", d.errors.on(:name).first
    end
    GetText.set_locale_all "en"
    d = Developer.new
    d.name = "Joe"
    assert !d.valid?
    if AR_6657
      assert_equal "Name contains 'single' and \"double\" quotes", d.errors.on(:name).last
    else
      assert_equal "Name contains 'single' and \"double\" quotes", d.errors.on(:name).first
    end
  end

  def test_validates_length_of_with_custom_message_using_quotes
    GetText.set_locale_all "ja_JP.UTF-8"
    Developer.validates_length_of :name, :minimum => 4, :message=> N_("This string contains 'single' and \"double\" quotes")
    d = Developer.new
    d.name = "Joe"
    assert !d.valid?
    if AR_6657
      assert_equal "この文字列は'シングル' \"ダブル\"クオートを含む。", d.errors.on(:name).last
    else
      assert_equal "この文字列は'シングル' \"ダブル\"クオートを含む。", d.errors.on(:name).first
    end
    GetText.set_locale_all "en"
    d = Developer.new
    d.name = "Joe"
    assert !d.valid?
    if AR_6657
      assert_equal "This string contains 'single' and \"double\" quotes", d.errors.on(:name).last
    else
      assert_equal "This string contains 'single' and \"double\" quotes", d.errors.on(:name).first
    end
  end

  def test_validates_presence_of_with_custom_message_using_quotes_fn
    # This test depends on test_validates_presence_of_with_custom_message_using_quotes
    GetText.set_locale_all "ja_JP.UTF-8"
    Developer.validates_presence_of :non_existent, :message=> N_("%{fn} contains 'single' and \"double\" quotes")
    d = Developer.new
    d.name = "Joe"
    assert !d.valid?

    if AR_6657
      assert_equal "存在しないは'シングル' \"ダブル\"クオートを含む。", d.errors.on(:non_existent).last
    else
      assert_equal "存在しないは'シングル' \"ダブル\"クオートを含む。", d.errors.on(:non_existent).first
    end
    GetText.set_locale_all "en"
    d = Developer.new
    d.name = "Joe"
    assert !d.valid?
    if AR_6657
      assert_equal "Non existent contains 'single' and \"double\" quotes", d.errors.on(:non_existent).last
    else
      assert_equal "Non existent contains 'single' and \"double\" quotes", d.errors.on(:non_existent).first
    end
  end

  def test_validates_presence_of_with_custom_message_using_quotes
    GetText.set_locale_all "ja_JP.UTF-8"
    Developer.validates_presence_of :non_existent, :message=> N_("This string contains 'single' and \"double\" quotes")
    d = Developer.new
    d.name = "Joe"
    assert !d.valid?
    assert_equal "この文字列は'シングル' \"ダブル\"クオートを含む。", d.errors.on(:non_existent)
    GetText.set_locale_all "en"
    d = Developer.new
    d.name = "Joe"
    assert !d.valid?
    assert_equal "This string contains 'single' and \"double\" quotes", d.errors.on(:non_existent)
  end

  def test_validates_uniqueness_of_with_custom_message_using_quotes_fn
    Developer.validates_uniqueness_of :name, :message=> N_("%{fn} contains 'single' and \"double\" quotes")

    GetText.set_locale_all "ja_JP.UTF-8"
    d = Developer.new
    d.name = "David"
    assert !d.valid?
    if AR_6657
      assert_equal d.errors.on(:name).last, "開発者名は'シングル' \"ダブル\"クオートを含む。"
    else
      assert_equal d.errors.on(:name).first, "開発者名は'シングル' \"ダブル\"クオートを含む。"
    end

    GetText.set_locale_all "en"
    d = Developer.new
    d.name = "David"
    assert !d.valid?
    if AR_6657
      assert_equal d.errors.on(:name).last, "Name contains 'single' and \"double\" quotes"
    else
      assert_equal d.errors.on(:name).first, "Name contains 'single' and \"double\" quotes"
    end
  end

  def test_validates_uniqueness_of_with_custom_message_using_quotes
    Developer.validates_uniqueness_of :name, :message=> N_("This string contains 'single' and \"double\" quotes")

    GetText.set_locale_all "ja_JP.UTF-8"
    d = Developer.new
    d.name = "David"
    assert !d.valid?
    if AR_6657
      assert_equal d.errors.on(:name).first, "この文字列は'シングル' \"ダブル\"クオートを含む。"
    else
      assert_equal d.errors.on(:name).last, "この文字列は'シングル' \"ダブル\"クオートを含む。"
    end
    GetText.set_locale_all "en"
    d = Developer.new
    d.name = "David"
    assert !d.valid?
    if AR_6657
      assert_equal d.errors.on(:name).first, "This string contains 'single' and \"double\" quotes"
    else
      assert_equal d.errors.on(:name).last, "This string contains 'single' and \"double\" quotes"
    end
  end

  def test_validates_associated_with_custom_message_using_quotes_fn
    Reply.validates_associated :topic, :message => N_("%{fn} contains 'single' and \"double\" quotes")
    Topic.validates_presence_of :content
    r = Reply.create("title" => "A reply", "content" => "with content!")
    r.topic = Topic.create("title" => "uhohuhoh")
    assert !r.valid?
    assert r.errors.on(:topic)
    r.topic.content = "non-empty"
    assert r.valid?

    GetText.set_locale_all "ja_JP.UTF-8"
    r = Reply.create("title" => "A reply", "content" => "with content!")
    r.topic = Topic.create("title" => "uhohuhoh")
    assert !r.valid?
    if AR_6657
      assert_equal "Replyトピックは'シングル' \"ダブル\"クオートを含む。", r.errors.on(:topic).last 
    else
      assert_equal "Replyトピックは'シングル' \"ダブル\"クオートを含む。", r.errors.on(:topic).first
    end

    GetText.set_locale_all "en"
    r = Reply.create("title" => "A reply", "content" => "with content!")
    r.topic = Topic.create("title" => "uhohuhoh")
    assert !r.valid?
    if AR_6657
      assert_equal "Topic contains 'single' and \"double\" quotes", r.errors.on(:topic).last 
    else
      assert_equal "Topic contains 'single' and \"double\" quotes", r.errors.on(:topic).first
    end
  end

  def test_validates_associated_with_custom_message_using_quotes
    Reply.validates_associated :topic, :message => N_("This string contains 'single' and \"double\" quotes")
    Topic.validates_presence_of :content
    r = Reply.create("title" => "A reply", "content" => "with content!")
    r.topic = Topic.create("title" => "uhohuhoh")
    assert !r.valid?
    assert r.errors.on(:topic)
    r.topic.content = "non-empty"
    assert r.valid?

    GetText.set_locale_all "ja_JP.UTF-8"
    r = Reply.create("title" => "A reply", "content" => "with content!")
    r.topic = Topic.create("title" => "uhohuhoh")
    assert !r.valid?
    assert_equal "この文字列は'シングル' \"ダブル\"クオートを含む。", r.errors.on(:topic)

    GetText.set_locale_all "en"
    r = Reply.create("title" => "A reply", "content" => "with content!")
    r.topic = Topic.create("title" => "uhohuhoh")
    assert !r.valid?
    assert_equal "This string contains 'single' and \"double\" quotes", r.errors.on(:topic)
  end

=begin
  def test_if_validation_using_method_true
  end
  def test_unless_validation_using_method_true
  end
  def test_if_validation_using_method_false
  end
=end
  def test_unless_validation_using_method_false_fn
    # When the method returns false
    Topic.validates_length_of( :title, :maximum=>5, :too_long=>N_("%{fn} hoo %d"), :unless => :condition_is_true_but_its_not )

    GetText.set_locale_all "ja"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "タイトルふー5", t.errors.full_messages[0]
    assert_equal "タイトルふー5", t.errors["title"]

    GetText.set_locale_all "en"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title hoo 5", t.errors.full_messages[0]
    assert_equal "Title hoo 5", t.errors["title"]
  end

  def test_unless_validation_using_method_false
    # When the method returns false
    Topic.validates_length_of( :title, :maximum=>5, :too_long=>N_("hoo %d"), :unless => :condition_is_true_but_its_not )

    GetText.set_locale_all "ja"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "タイトル ふー5", t.errors.full_messages[0]
    assert_equal "ふー5", t.errors["title"]

    GetText.set_locale_all "en"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title hoo 5", t.errors.full_messages[0]
    assert_equal "hoo 5", t.errors["title"]
  end

  def test_if_validation_using_string_true_fn
    # When the evaluated string returns true
    Topic.validates_length_of( :title, :maximum=>5, :too_long=>N_("%{fn} hoo %d"), :if => "a = 1; a == 1" )

    GetText.set_locale_all "ja"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "タイトルふー5", t.errors.full_messages[0]
    assert_equal "タイトルふー5", t.errors["title"]

    GetText.set_locale_all "en"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title hoo 5", t.errors.full_messages[0]
    assert_equal "Title hoo 5", t.errors["title"]
  end

  def test_if_validation_using_string_true
    # When the evaluated string returns true
    Topic.validates_length_of( :title, :maximum=>5, :too_long=>N_("hoo %d"), :if => "a = 1; a == 1" )

    GetText.set_locale_all "ja"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "タイトル ふー5", t.errors.full_messages[0]
    assert_equal "ふー5", t.errors["title"]

    GetText.set_locale_all "en"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title hoo 5", t.errors.full_messages[0]
    assert_equal "hoo 5", t.errors["title"]
  end

=begin
  def test_unless_validation_using_string_true
  end
  def test_if_validation_using_string_false
  end
=end
  def test_unless_validation_using_string_false
    # When the evaluated string returns false
    Topic.validates_length_of( :title, :maximum=>5, :too_long=>N_("hoo %d"), :unless => "false")

    GetText.set_locale_all "ja"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "タイトル ふー5", t.errors.full_messages[0]
    assert_equal "ふー5", t.errors["title"]

    GetText.set_locale_all "en"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title hoo 5", t.errors.full_messages[0]
    assert_equal "hoo 5", t.errors["title"]
  end

  def test_if_validation_using_block_true_fn
    # When the block returns true
    Topic.validates_length_of( :title, :maximum=>5, :too_long=>N_("%{fn} hoo %d"),
      :if => Proc.new { |r| r.content.size > 4 } )

    GetText.set_locale_all "ja"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "タイトルふー5", t.errors.full_messages[0]
    assert_equal "タイトルふー5", t.errors["title"]

    GetText.set_locale_all "en"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title hoo 5", t.errors.full_messages[0]
    assert_equal "Title hoo 5", t.errors["title"]
  end

  def test_if_validation_using_block_true
    # When the block returns true
    Topic.validates_length_of( :title, :maximum=>5, :too_long=>N_("hoo %d"),
      :if => Proc.new { |r| r.content.size > 4 } )

    GetText.set_locale_all "ja"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "タイトル ふー5", t.errors.full_messages[0]
    assert_equal "ふー5", t.errors["title"]

    GetText.set_locale_all "en"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title hoo 5", t.errors.full_messages[0]
    assert_equal "hoo 5", t.errors["title"]
  end

  def test_conditional_validation_using_method_true_fn
    # When the method returns true
    Topic.validates_length_of( :title, :maximum=>5, :too_long=> N_("%{fn} hoo %d"), :if => :condition_is_true )
    GetText.set_locale_all "ja_JP.UTF-8"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "タイトルふー5", t.errors.full_messages[0]
    assert_equal "タイトルふー5", t.errors.on("title")

    GetText.set_locale_all "en"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title hoo 5", t.errors.full_messages[0]
    assert_equal "Title hoo 5", t.errors.on("title")
  end

=begin
  Don't need this
  def test_unless_validation_using_block_true
  end
  def test_if_validation_using_block_false
  end
=end

  def test_unless_validation_using_block_false_fn
    # When the block returns false
    Topic.validates_length_of( :title, :maximum=>5, :too_long=>N_("%{fn} hoo %d"),
      :unless => Proc.new { |r| r.title != "uhohuhoh"} )

    GetText.set_locale_all "ja_JP.UTF-8"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "タイトルふー5", t.errors.full_messages[0]
    assert_equal "タイトルふー5", t.errors.on("title")

    GetText.set_locale_all "en"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title hoo 5", t.errors.full_messages[0]
    assert_equal "Title hoo 5", t.errors["title"]
  end

  def test_unless_validation_using_block_false
    # When the block returns false
    Topic.validates_length_of( :title, :maximum=>5, :too_long=>N_("hoo %d"),
      :unless => Proc.new { |r| r.title != "uhohuhoh"} )

    GetText.set_locale_all "ja_JP.UTF-8"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "タイトル ふー5", t.errors.full_messages[0]
    assert_equal "ふー5", t.errors.on("title")

    GetText.set_locale_all "en"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title hoo 5", t.errors.full_messages[0]
    assert_equal "hoo 5", t.errors["title"]
  end

  def test_conditional_validation_using_method_true
    # When the method returns true
    Topic.validates_length_of( :title, :maximum=>5, :too_long=> N_("hoo %d"), :if => :condition_is_true )
    GetText.set_locale_all "ja_JP.UTF-8"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "タイトル ふー5", t.errors.full_messages[0]
    assert_equal "ふー5", t.errors.on("title")

    GetText.set_locale_all "en"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title hoo 5", t.errors.full_messages[0]
    assert_equal "hoo 5", t.errors.on("title")
  end

  def test_conditional_validation_using_string_true_fn
    # When the evaluated string returns true
    Topic.validates_length_of( :title, :maximum=>5, :too_long=> N_("%{fn} hoo %d"), :if => "a = 1; a == 1" )

    GetText.set_locale_all "ja_JP.UTF-8"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "タイトルふー5", t.errors.full_messages[0]
    assert_equal "タイトルふー5", t.errors.on("title")

    GetText.set_locale_all "en"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title hoo 5", t.errors.full_messages[0]
    assert_equal "Title hoo 5", t.errors.on("title")
  end

  def test_conditional_validation_using_string_true
    # When the evaluated string returns true
    Topic.validates_length_of( :title, :maximum=>5, :too_long=> N_("hoo %d"), :if => "a = 1; a == 1" )

    GetText.set_locale_all "ja_JP.UTF-8"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "タイトル ふー5", t.errors.full_messages[0]
    assert_equal "ふー5", t.errors.on("title")

    GetText.set_locale_all "en"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title hoo 5", t.errors.full_messages[0]
    assert_equal "hoo 5", t.errors.on("title")
  end

  def test_conditional_validation_using_block_true_fn
    # When the block returns true
    GetText.set_locale_all "ja_JP.UTF-8"
    Topic.validates_length_of( :title, :maximum=>5, :too_long => N_("%{fn} hoo %d"),
      :if => Proc.new { |r| r.content.size > 4 } )
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "タイトルふー5", t.errors.full_messages[0]
    assert_equal "タイトルふー5", t.errors.on("title")

    GetText.set_locale_all "en"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title hoo 5", t.errors.full_messages[0]
    assert_equal "Title hoo 5", t.errors.on("title")

  end

  def test_conditional_validation_using_block_true
    # When the block returns true
    GetText.set_locale_all "ja_JP.UTF-8"
    Topic.validates_length_of( :title, :maximum=>5, :too_long => N_("hoo %d"),
      :if => Proc.new { |r| r.content.size > 4 } )
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "タイトル ふー5", t.errors.full_messages[0]
    assert_equal "ふー5", t.errors.on("title")

    GetText.set_locale_all "en"
    t = Topic.create("title" => "uhohuhoh", "content" => "whatever")
    assert !t.valid?
    assert t.errors.on(:title)
    assert_equal "Title hoo 5", t.errors.full_messages[0]
    assert_equal "hoo 5", t.errors.on("title")

  end

  def test_validates_associated_missing
    GetText.set_locale_all "ja_JP.UTF-8"
    Reply.validates_presence_of(:topic)
    r = Reply.create("title" => "A reply", "content" => "with content!")
    # In this case, rgettext doesn't pick up the names of relations as msgid, 
    # so you need to define N_() in the model class
    assert_equal "Replyトピックを入力してください。",  r.errors.on(:topic)

    GetText.set_locale_all "en"
    r = Reply.create("title" => "A reply", "content" => "with content!")
    assert_equal "Topic can't be blank",  r.errors.on(:topic)
    assert_equal "Topic can't be blank",  r.errors.full_messages[0]
  end

  def test_errors_to_xml
    GetText.set_locale_all "ja_JP.UTF-8"
    r = Reply.new :title => "Wrong Create"
    assert !r.valid?
    xml = r.errors.to_xml(:skip_instruct => true)
    assert_equal "<errors>", xml.first(8)
    assert xml.include?("<error>Reply&#12479;&#12452;&#12488;&#12523; &#12364;&#19981;&#27491;&#12395;&#29983;&#25104;&#12373;&#12428;&#12414;&#12375;&#12383;&#12290;</error>")
    assert xml.include?("<error>Reply&#20869;&#23481; &#31354;&#12391;&#12377;&#12290;</error>")

    GetText.set_locale_all "en"
    r = Reply.new :title => "Wrong Create"
    assert !r.valid?
    xml = r.errors.to_xml(:skip_instruct => true)
    assert_equal "<errors>", xml.first(8)
    assert xml.include?("<error>Title is Wrong Create</error>")
    assert xml.include?("<error>Content Empty</error>")
  end

  def test_validation_order
    if AR_6657
      Topic.validates_presence_of :title
      Topic.validates_length_of :title, :minimum => 2
      
      GetText.set_locale_all "ja_JP.UTF-8"
      t = Topic.new("title" => "")
      assert !t.valid?
      assert_equal "タイトルを入力してください。", t.errors.on("title").first
      
      GetText.set_locale_all "en"
      t = Topic.new("title" => "")
      assert !t.valid?
      assert_equal "Title can't be blank", t.errors.on("title").first
    end
  end

=begin
  #Don't need this
  def test_validation_with_if_as_string
  end
=end

  def test_default_validates_numericality_of
    GetText.set_locale_all "ja_JP.UTF-8"
    Topic.validates_numericality_of :approved
    topic = Topic.create("title" => "numeric test", "content" => "whatever", "approved" => "aaa")
    assert_equal "承認は数値で入力してください。", topic.errors.on(:approved)

    GetText.set_locale_all "en"
    topic = Topic.create("title" => "numeric test", "content" => "whatever", "approved" => "aaa")
    assert_equal "Approved is not a number", topic.errors.on(:approved)
    assert_equal "Approved is not a number", topic.errors.full_messages[0]
  end

  def test_inherited_messages
    GetText.set_locale_all "ja_JP.UTF-8"
    Topic.validates_presence_of(:title, :content)

    GetText.set_locale_all "ja_JP.UTF-8"
    t = Topic.create
    assert !t.save
    assert_equal "タイトルを入力してください。", t.errors.full_messages[0]
    assert_equal "内容を入力してください。", t.errors.full_messages[1]
    assert_equal "タイトルを入力してください。", t.errors.on(:title)
    assert_equal "内容を入力してください。", t.errors.on(:content)

    t = Reply.create
    assert !t.save
    assert_equal "Replyタイトルを入力してください。", t.errors.full_messages[0]
    assert_equal "Replyタイトル 空です。", t.errors.full_messages[1]
    assert_equal "Reply内容を入力してください。", t.errors.full_messages[2]
    assert_equal "Reply内容 空です。", t.errors.full_messages[3]
    assert_equal ["Replyタイトルを入力してください。","空です。"], t.errors.on(:title)
    assert_equal ["Reply内容を入力してください。", "空です。"], t.errors.on(:content)

    t = Reply.create
    t.title = "Wrong Create"
    assert !t.save
    assert_equal "Replyタイトル が不正に生成されました。", t.errors.full_messages[0]
    assert_equal "Reply内容を入力してください。", t.errors.full_messages[1]
    assert_equal "Reply内容 空です。", t.errors.full_messages[2]

    t = SillyReply.create
    assert !t.save
    assert_equal "Sillyタイトルを入力してください。", t.errors.full_messages[0]
    assert_equal "Sillyタイトル 空です。", t.errors.full_messages[1]
    assert_equal "Silly内容を入力してください。", t.errors.full_messages[2]
    assert_equal "Silly内容 空です。", t.errors.full_messages[3]
    assert_equal ["Sillyタイトルを入力してください。","空です。"], t.errors.on(:title)
    assert_equal ["Silly内容を入力してください。","空です。"], t.errors.on(:content)

    t = SillyReply.create
    t.title = "Wrong Create"
    assert !t.save
    assert_equal "Sillyタイトル が不正に生成されました。", t.errors.full_messages[0]
    assert_equal "Silly内容を入力してください。", t.errors.full_messages[1]
    assert_equal "Silly内容 空です。", t.errors.full_messages[2]
  end

  def test_original_model_with_validation
    GetText.set_locale_all "ja_JP.UTF-8"
    t = MyModel.new
    t.title = nil
    t.save
    assert_equal "Titleを入力してください。", t.errors.full_messages[0]
    assert_equal "Titleを入力してください。", t.errors.on(:title)

    GetText.set_locale_all "en"
    t = MyModel.new
    t.title = nil
    t.save
    assert_equal "Title can't be blank", t.errors.full_messages[0]
    assert_equal "Title can't be blank", t.errors.on(:title)
  end
end

class ValidatesNumericalityTest < Test::Unit::TestCase
  include GetText

  NIL = [nil]
  BLANK = ["", " ", " \t \r \n"]
  BIGDECIMAL_STRINGS = %w(12345678901234567890.1234567890) # 30 significent digits
  FLOAT_STRINGS = %w(0.0 +0.0 -0.0 10.0 10.5 -10.5 -0.0001 -090.1 90.1e1 -90.1e5 -90.1e-5 90e-5)
  INTEGER_STRINGS = %w(0 +0 -0 10 +10 -10 0090 -090)
  FLOATS = [0.0, 10.0, 10.5, -10.5, -0.0001] + FLOAT_STRINGS
  INTEGERS = [0, 10, -10] + INTEGER_STRINGS
  BIGDECIMAL = BIGDECIMAL_STRINGS.collect! { |bd| BigDecimal.new(bd) }
  JUNK = ["not a number", "42 not a number", "0xdeadbeef", "00-1", "--3", "+-3", "+3-1", "-+019.0", "12.12.13.12", "123\nnot a number"]

  def setup
    bindtextdomain_to(Topic, "active_record")

    Topic.instance_variable_set("@validate_callbacks", ActiveSupport::Callbacks::CallbackChain.new)
    Topic.instance_variable_set("@validate_on_create_callbacks", ActiveSupport::Callbacks::CallbackChain.new)
    Topic.instance_variable_set("@validate_on_update_callbacks", ActiveSupport::Callbacks::CallbackChain.new)
  end

  def test_default_validates_numericality_of
    Topic.validates_numericality_of :approved

    invalid!(NIL + BLANK + JUNK)
#    valid!(FLOATS + INTEGERS + BIGDECIMAL)
  end

  def test_validates_numericality_of_with_nil_allowed
    Topic.validates_numericality_of :approved, :allow_nil => true

    invalid!(BLANK + JUNK)
 #   valid!(NIL + FLOATS + INTEGERS + BIGDECIMAL)
  end

  def test_validates_numericality_of_with_integer_only
    Topic.validates_numericality_of :approved, :only_integer => true

    invalid!(NIL + BLANK + JUNK + FLOATS + BIGDECIMAL)
 #   valid!(INTEGERS)
  end

  def test_validates_numericality_of_with_integer_only_and_nil_allowed
    Topic.validates_numericality_of :approved, :only_integer => true, :allow_nil => true

    invalid!(BLANK + JUNK + FLOATS + BIGDECIMAL)
 #   valid!(NIL + INTEGERS)
  end

  def test_validates_numericality_with_greater_than
    Topic.validates_numericality_of :approved, :greater_than => 10

    invalid!([-10, 10], 'Approved must be greater than 10',
             '承認は10より大きい値にしてください。')
#    valid!([11])
  end

  def test_validates_numericality_with_greater_than_or_equal
    Topic.validates_numericality_of :approved, :greater_than_or_equal_to => 10

    invalid!([-9, 9], 'Approved must be greater than or equal to 10',
             "承認は10以上の値にしてください。")
 #   valid!([10])
  end

  def test_validates_numericality_with_equal_to
    Topic.validates_numericality_of :approved, :equal_to => 10

    invalid!([-10, 11], 'Approved must be equal to 10',
             "承認は10にしてください。")
 #   valid!([10])
  end

  def test_validates_numericality_with_less_than
    Topic.validates_numericality_of :approved, :less_than => 10

    invalid!([10], 'Approved must be less than 10',
             "承認は10より小さい値にしてください。")
 #   valid!([-9, 9])
  end

  def test_validates_numericality_with_less_than_or_equal_to
    Topic.validates_numericality_of :approved, :less_than_or_equal_to => 10

    invalid!([11], 'Approved must be less than or equal to 10')
 #   valid!([-10, 10])
  end

  def test_validates_numericality_with_odd
    Topic.validates_numericality_of :approved, :odd => true

    invalid!([-2, 2], 'Approved must be odd',
             "承認は奇数にしてください。")
 #   valid!([-1, 1])
  end

  def test_validates_numericality_with_even
    Topic.validates_numericality_of :approved, :even => true

    invalid!([-1, 1], 'Approved must be even',
             "承認は偶数にしてください。")
 #   valid!([-2, 2])
  end

  def test_validates_numericality_with_greater_than_less_than_and_even
    Topic.validates_numericality_of :approved, :greater_than => 1, :less_than => 4, :even => true

    invalid!([1, 3, 4])
 #   valid!([2])
  end

  def test_validates_numericality_with_numeric_message
    Topic.validates_numericality_of :approved, :less_than => 4, :message => N_("smaller than %d")
    topic = Topic.new("title" => "numeric test", "approved" => 10)

    assert !topic.valid?
    assert_equal "Approved smaller than 4", topic.errors.full_messages[0]
    assert_equal "smaller than 4", topic.errors.on(:approved)

    Topic.validates_numericality_of :approved, :greater_than => 4, :message => N_("greater than %d")
    topic = Topic.new("title" => "numeric test", "approved" => 1)

    assert !topic.valid?
    assert_equal "Approved greater than 4", topic.errors.full_messages[0]
    assert_equal "greater than 4", topic.errors.on(:approved)
  end

  private
    def invalid!(values, error=nil, errorj=nil)
      with_each_topic_approved_value(values) do |topic, value|
        GetText.set_locale_all "ja"
        assert !topic.valid?, "#{value.inspect} not rejected as a number"
        assert topic.errors.on(:approved)
        assert_equal errorj, topic.errors.full_messages[0] if errorj
        assert_equal errorj, topic.errors.on(:approved) if errorj
      end

      with_each_topic_approved_value(values) do |topic, value|
        GetText.set_locale_all "en"
        assert !topic.valid?, "#{value.inspect} not rejected as a number"
        assert topic.errors.on(:approved)
        assert_equal error, topic.errors.full_messages[0] if error
        assert_equal error, topic.errors.on(:approved) if error
      end
    end
=begin
    # Don't need this
    def valid!(values)
      with_each_topic_approved_value(values) do |topic, value|
        assert topic.valid?, "#{value.inspect} not accepted as a number"
      end
    end
=end
    def with_each_topic_approved_value(values)
      topic = Topic.new("title" => "numeric test", "content" => "whatever")
      values.each do |value|
        topic.approved = value
        yield topic, value
      end
    end
end
