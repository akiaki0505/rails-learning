require 'csv'

class User < ApplicationRecord
  belongs_to :department, optional: true
  has_many :surveys, dependent: :destroy

  validates :password, length: { minimum: 8 }, allow_nil: true
  validates :email, presence: true, uniqueness: true
  validates :name, :department_id, presence: true

  has_secure_password

  def self.generate_csv(user_data)
    csv_attributes = %w{ID 名前 メールアドレス 登録日時}

    csv_string = CSV.generate(headers: true) do |csv|
      csv << csv_attributes
      user_data.each do |user|
        csv << [
          user.id, 
          user.name, 
          user.email, 
          user.created_at.strftime("%Y-%m-%d %H:%M:%S")
        ]
      end
    end

    return "\uFEFF#{csv_string}"
  end
end
