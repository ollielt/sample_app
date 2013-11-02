class User < ActiveRecord::Base
  has_many :microposts, dependent: :destroy
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :followed_users, through: :relationships, source: :followed
  has_many :reverse_relationships, foreign_key: "followed_id",
                                   class_name: "Relationship",
                                   dependent: :destroy
  has_many :followers, through: :reverse_relationships, source: :follower
  validates :name, presence: true, length: { maximum: 50 }
  before_save { self.email = email.downcase }
  before_create { generate_token(:auth_token) }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  validates :email, presence: true,
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :password, presence: true,
                       length: { within: 6..40 }, if: :should_validate_password?
  has_secure_password
  
  def User.new_auth_token
    SecureRandom.urlsafe_base64
  end
  
  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end
  
  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.password_reset(self).deliver
  end

  def feed
    Micropost.from_users_followed_by(self)
  end
    
  def following?(other_user)
    relationships.find_by(followed_id: other_user.id)
  end
    
  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end
    
  def unfollow!(other_user)
    relationships.find_by(followed_id: other_user.id).destroy!
  end
    
  private
  
    def generate_token(column)
      begin
        self[column] = User.encrypt(User.new_auth_token)
      end while User.exists?(column ||= self[column])
    end
    
    def should_validate_password?
      !persisted? || !password.nil? || !password_confirmation.nil?
    end
end
