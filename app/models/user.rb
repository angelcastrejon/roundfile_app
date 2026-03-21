class User < ApplicationRecord
  has_secure_password

  has_many :resumes, dependent: :destroy
  has_many :sections, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :ratings, dependent: :destroy

  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }
  validates :password, length: { minimum: 8 }, allow_nil: true

  normalizes :email, with: ->(email) { email.strip.downcase }

  # --- Password reset --------------------------------------------------------

  RESET_TOKEN_EXPIRY = 2.hours

  def generate_password_reset!
    raw_token = SecureRandom.urlsafe_base64(32)
    update_columns(
      password_reset_token_digest: Digest::SHA256.hexdigest(raw_token),
      password_reset_sent_at: Time.current
    )
    raw_token
  end

  def self.find_by_reset_token(token)
    return nil if token.blank?

    digest = Digest::SHA256.hexdigest(token)
    user = find_by(password_reset_token_digest: digest)
    user if user&.password_reset_sent_at &.> RESET_TOKEN_EXPIRY.ago
  end

  def clear_password_reset!
    update_columns(password_reset_token_digest: nil, password_reset_sent_at: nil)
  end

  # --- Gravatar --------------------------------------------------------------

  def gravatar_url(size: 80)
    hash = Digest::MD5.hexdigest(email)
    "https://www.gravatar.com/avatar/#{hash}?s=#{size}&d=identicon"
  end
end
