# Testing app setup

##################
# Database schema
##################

ActiveRecord::Migration.suppress_messages do
  ActiveRecord::Schema.define(:version => 0) do
    create_table :users, :force => true do |t|
      t.column "type", :string
    end
    
    create_table :posts, :force => true do |t|
      t.column "author_id", :integer
      t.column "category_id", :integer
      t.column "inflamatory", :boolean
    end

    create_table :categories, :force => true do |t|
    end

    create_table :comments, :force => true do |t|
      t.column "user_id", :integer
      t.column "post_id", :integer
    end

    create_table :events, :force => true do |t|
      t.string :name
    end

    create_table :event_associates, :force => true do |t|
      t.references :event
      t.references :associate, :polymorphic => true
    end

    create_table :event_associates, :force => true do |t|
      t.references :event
      t.references :associate, :polymorphic => true
    end

    create_table :invitees, :force => true do |t|
      t.string :name
      t.references :tribe
    end

    create_table :tribes, :force => true do |t|
      t.string :name
    end

    create_table :invitations, :force => true do |t|
      t.references :invitee
      t.boolean :attending
    end

    create_table :countries, :force => true do |t|
      t.string :name
    end

    create_table :citizenships, :force => true do |t|
      t.references :country
      t.references :citizen
    end

    create_table :citizens, :force => true do |t|
      t.string :name
    end
  end
end

#########
# Models
#
# Domain model is this:
#
#   - authors (type of user) can create posts in categories
#   - users can comment on posts
#   - authors have similar_posts: posts in the same categories as ther posts
#   - authors have similar_authors: authors of the recommended_posts
#   - authors have posts_of_similar_authors: all posts by similar authors (not just the similar posts,
#                                            similar_posts is be a subset of this collection)
#   - authors have commenters: users who have commented on their posts
#
class User < ActiveRecord::Base
  has_many :comments
  has_many :commented_posts, :through => :comments, :source => :post, :uniq => true
  has_many :commented_authors, :through => :commented_posts, :source => :author, :uniq => true
  has_many :posts_of_interest, :through => :commented_authors, :source => :posts_of_similar_authors, :uniq => true
  has_many :categories_of_interest, :through => :posts_of_interest, :source => :category, :uniq => true
end

class Author < User
  has_many :posts
  has_many :categories, :through => :posts
  has_many :similar_posts, :through => :categories, :source => :posts
  has_many :similar_authors, :through => :similar_posts, :source => :author, :uniq => true
  has_many :posts_of_similar_authors, :through => :similar_authors, :source => :posts, :uniq => true
  has_many :commenters, :through => :posts, :uniq => true
end

class Post < ActiveRecord::Base
  
  # testing with_scope
  def self.find_inflamatory(*args)
    with_scope :find => {:conditions => {:inflamatory => true}} do
      find(*args)
    end
  end

  # only test named_scope in edge
  named_scope(:inflamatory, :conditions => {:inflamatory => true}) if respond_to?(:named_scope)
  
  belongs_to :author
  belongs_to :category
  has_many :comments
  has_many :commenters, :through => :comments, :source => :user, :uniq => true
end

class Category < ActiveRecord::Base
  has_many :posts
end

class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :post
end

class Invitee < ActiveRecord::Base
  belongs_to :tribe
  has_many :invitations
  has_many :events, :through => :invitations
end

class Invitation < ActiveRecord::Base
  belongs_to :invitee
  has_one :event_associate, :as => :associate
  has_one :event, :through => :event_associate
end

class EventAssociate < ActiveRecord::Base
  belongs_to :event
  belongs_to :associate, :polymorphic => true
end

class Event < ActiveRecord::Base
  has_many :event_associates
  has_many :invitations, :through => :event_associates, :source => :associate, :source_type => Invitation.name
  has_many :invitees, :through => :invitations
  has_many :attendees, :through => :invitations, :source => :invitee, :conditions => ['attending = ?', true], :before_add => [:before_attendee_add]
  has_many :tribes, :through => :invitees

  def before_attendee_add attendee, invitation_params
    invitation_params[:attending] = true
  end
end

class Tribe < ActiveRecord::Base; end

class Country < ActiveRecord::Base
  has_many :citizenships
  has_many :citizens, :through => :citizenships, :before_add => [:before_citizen_add]

  def before_citizen_add; end
end

class Citizenship < ActiveRecord::Base
  belongs_to :country
  belongs_to :citizen
end

class Citizen < ActiveRecord::Base; end