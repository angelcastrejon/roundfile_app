class Section < ApplicationRecord
  TYPES = [
    "Contact",
    "Objective",
    "Qualifications",
    "Education",
    "Skills",
    "Employment History",
    "References",
    "Other"
  ].freeze

  belongs_to :user

  has_many :resume_sections, dependent: :destroy
  has_many :resumes, through: :resume_sections

  validates :section_type, presence: true, inclusion: { in: TYPES }
  validates :title, presence: true
  validates :content, presence: true
end
