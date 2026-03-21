class Comment < ApplicationRecord
  belongs_to :resume
  belongs_to :user

  validates :body, presence: true
end
