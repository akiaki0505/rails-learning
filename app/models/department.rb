class Department < ApplicationRecord
  belongs_to :headquarter
  has_many :users, dependent: :nullify
  has_many :surveys, through: :users
  has_many :surveys, dependent: :destroy

  def average_score
    surveys.average(:total_score)&.to_f&.round(1)
  end

end
