class Resume < ApplicationRecord
  belongs_to :user

  has_many :resume_sections, -> { order(:position) }, dependent: :destroy
  has_many :sections, through: :resume_sections
  has_many :comments, dependent: :destroy
  has_many :ratings, dependent: :destroy

  validates :name, presence: true

  def average_rating
    ratings.average(:score)&.round(1) || 0
  end
end
