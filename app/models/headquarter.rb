class Headquarter < ApplicationRecord
  has_many :departments, dependent: :destroy
  has_many :surveys, dependent: :destroy

  validates :name, presence: true
end
