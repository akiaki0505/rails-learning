class Headquarter < ApplicationRecord
  has_many :departments, dependent: :destroy
end
