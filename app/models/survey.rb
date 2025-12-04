class Survey < ApplicationRecord
  belongs_to :user
  before_save :calculate_total_score
  
  private
  def calculate_total_score
    self.total_score = q1.to_i + q2.to_i + q3.to_i + q4.to_i + q5.to_i
  end
end
