class Department < ApplicationRecord
  belongs_to :headquarter
  has_many :users, dependent: :nullify
  has_many :surveys, through: :users

  def average_score
    surveys.average(:total_score)&.to_f&.round(1)
  end

end
