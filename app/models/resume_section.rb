class ResumeSection < ApplicationRecord
  belongs_to :resume
  belongs_to :section

  validates :position, presence: true
  validates :section_id, uniqueness: { scope: :resume_id }
end
