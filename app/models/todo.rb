class Todo < ApplicationRecord
    validates :title, presence: true, presence: { message: "タイトルを必ず入力してください" }, allow_blank: false
    validates :body, presence: true, presence: { message: "ボディーを必ず入力してください" }, allow_blank: false
end
