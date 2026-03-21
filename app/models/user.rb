class User < ApplicationRecord
  has_secure_password

  has_many :resumes, dependent: :destroy
  has_many :sections, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :ratings, dependent: :destroy

  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }
  validates :password, length: { minimum: 6 }, allow_nil: true

  normalizes :email, with: ->(email) { email.strip.downcase }

  def gravatar_url(size: 80)
    hash = Digest::MD5.hexdigest(email)
    "https://www.gravatar.com/avatar/#{hash}?s=#{size}&d=identicon"
  end
end
