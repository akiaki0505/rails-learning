class User < ApplicationRecord
  belongs_to :department, optional: true
  has_many :surveys, dependent: :destroy

  validates :password, length: { minimum: 8 }, allow_nil: true
  validates :name, :email, presence: true, uniqueness: true

  has_secure_password
end
