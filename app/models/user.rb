require 'securerandom'
class User < ActiveRecord::Base
  before_create :set_user_subdomain
  before_save :ensure_authentication_token
  # before_save :set_user_subdomain
  # before_save :set_user_feed_name
  after_create :set_user_feed
  after_create :generate_api_key
  after_create :send_welcome_email
  devise :database_authenticatable, :recoverable, :validatable, :token_authenticatable
  attr_accessible :email, :password, :password_confirmation, :display_name, :subdomain
  has_many :authentications
  has_many :tweets
  has_many :githubevents
  has_one :feed


  DISPLAY_NAME_REGEX = /^[\w-]*$/
  validates :display_name, 
    format: { with: DISPLAY_NAME_REGEX, message: "must be only letters, numbers, dashes, or underscores" },
    presence: true, 
    uniqueness: true,
    exclusion: { in: %w(www ftp api), message: "can not be www, ftp, or api" }

  def send_welcome_email
    UserMailer.welcome_email(self).deliver
  end

  def set_user_subdomain
    self.subdomain = self.display_name.downcase
  end

  def set_user_feed_name
    self.feed.set_name(self.subdomain)
  end

  def set_user_feed
    Feed.create(:user_id => self.id, :name => self.subdomain)
  end

  FEED_TYPES.each do |type_name|
    has_many type_name.to_s.to_sym
  end
  
  def posts
    FEED_TYPES.map do |association|
      self.send(association.to_s.to_sym).all
    end.flatten.uniq.compact.sort_by { |post| post.created_at }
  end
  
  def generate_api_key
    key = Digest::SHA256.hexdigest("#{SecureRandom.hex(15)}HuNgRyF33d#{Time.now}")
    key = generate_api_key if User.exists?(api_key: key)
    self.update_attribute(:api_key, key)
  end

  def twitter_id
    authentications.find_by_provider('twitter').uid
  end

  def github_handle
    authentications.find_by_provider('github').handle
  end
end