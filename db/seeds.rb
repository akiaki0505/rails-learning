# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# ---------------------------------------------
# 1. リセット処理 (開発環境用)
# ---------------------------------------------
puts "古いデータをクリーニング中..."

# 外部キー制約があるため、子(User) -> 孫(Department) -> 親(Headquarter) の順で処理
# 既存ユーザーを消したくない場合は、次の行を User.update_all(department_id: nil) に変えてください
User.where.not(email: 'admin@example.com').destroy_all # admin以外の全ユーザー削除の例

Department.destroy_all
Headquarter.destroy_all

puts "クリーニング完了"

# ---------------------------------------------
# 2. 本部と部署の作成
# ---------------------------------------------
puts "組織データの作成を開始します..."

# 定義したい組織図の配列
org_structure = [
  {
    name: "営業本部",
    code: "SALES",
    departments: ["営業第一部", "営業第二部", "マーケティング部"]
  },
  {
    name: "開発本部",
    code: "DEV",
    departments: ["システム開発部", "インフラ技術部", "UI/UXデザイン部"]
  },
  {
    name: "管理本部",
    code: "ADMIN",
    departments: ["人事部", "総務部", "経理部"]
  }
]

org_structure.each do |hq_data|
  # 本部の作成
  hq = Headquarter.create!(
    name: hq_data[:name],
    code: hq_data[:code]
  )
  puts "【本部】#{hq.name} を作成しました"

  # その本部に紐づく部署の作成
  hq_data[:departments].each_with_index do |dept_name, index|
    dept = hq.departments.create!(
      name: dept_name,
      code: "#{hq_data[:code]}_0#{index + 1}"
    )
    puts "  -> 【部署】#{dept.name} を作成しました"

    # ---------------------------------------------
    # 3. ダミーユーザーの作成 (各部署に3人ずつ追加)
    # ---------------------------------------------
    # ※Deviseやhas_secure_passwordを使っている想定です
    # ※不要であればここはコメントアウトしてください
    3.times do |n|
      User.create!(
        department_id: dept.id,
        name: "#{dept.name}の社員#{n + 1}",
        email: "user_#{dept.code}_#{n + 1}@example.com",
        password: 'password', # ログイン用パスワード
        password_confirmation: 'password'
      )
    end
  end
end

puts "===================================="
puts "  初期データの投入が完了しました！"
puts "  作成されたユーザー数: #{User.count}"
puts "===================================="