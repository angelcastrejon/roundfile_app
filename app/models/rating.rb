class Rating < ApplicationRecord
  belongs_to :resume
  belongs_to :user

  validates :score, presence: true, inclusion: { in: 1..5 }
  validates :user_id, uniqueness: { scope: :resume_id, message: "can only rate a resume once" }
end
