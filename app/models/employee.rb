class Employee < ApplicationRecord
  validates :employee_number, :name, :email, :department_name, presence: true
  validates :employee_number, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "is invalid format" }
end
