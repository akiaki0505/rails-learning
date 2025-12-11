# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# ---------------------------------------------
# 1. リセット処理 (開発環境用)
# ---------------------------------------------
puts "古いデータをクリーニング中..."

Survey.destroy_all
User.where.not(email: 'admin@example.com').destroy_all
Department.destroy_all
Headquarter.destroy_all

puts "クリーニング完了"

# ---------------------------------------------
# 2. 本部と部署、およびユーザーの作成
# ---------------------------------------------
puts "組織データとユーザーの作成を開始します..."

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
  hq = Headquarter.create!(
    name: hq_data[:name],
    code: hq_data[:code]
  )
  puts "【本部】#{hq.name} を作成しました"

  hq_data[:departments].each_with_index do |dept_name, index|
    dept = hq.departments.create!(
      name: dept_name,
      code: "#{hq_data[:code]}_0#{index + 1}"
    )
    puts "  -> 【部署】#{dept.name} を作成しました"

    # ダミーユーザー作成 (各部署3人)
    3.times do |n|
      User.create!(
        department_id: dept.id,
        name: "#{dept.name}の社員#{n + 1}",
        email: "user_#{dept.code}_#{n + 1}@example.com",
        password: 'password',
        password_confirmation: 'password'
      )
    end
  end
end

# ---------------------------------------------
# 4. Survey (ストレスチェック回答) データの作成
# ---------------------------------------------
puts "ストレスチェックデータの自動生成を開始します..."

dates = [4.weeks.ago, 3.weeks.ago, 2.weeks.ago, 1.week.ago]
comments = ["特になし", "最近疲れが取れない", "順調です", "人間関係悩み中", "残業が多い", "やりがいを感じる"]

User.all.each do |user|
  dept = user.department
  hq   = dept.headquarter

  # 本部ごとのストレス傾向
  # SALES -> High (悪い: 4~5点)
  # DEV   -> Low (良い: 1~2点)
  # ADMIN -> Normal (普通: 2~4点)
  tendency = case hq.code
             when 'SALES' then :high
             when 'DEV'   then :low
             else              :normal
             end

  dates.each do |date|
    posted_at = date + rand(-2..2).days

    # ▼▼▼ 修正箇所: 1問あたり1〜5点で生成 ▼▼▼
    scores = 5.times.map do
      case tendency
      when :high
        rand(4..5) # 高ストレス (合計20~25点)
      when :low
        rand(1..2) # 低ストレス (合計5~10点)
      else
        rand(2..4) # 普通 (合計10~20点)
      end
    end

    total = scores.sum # 最大25点

    Survey.create!(
      user_id: user.id,
      headquarter: hq,
      department: dept,
      q1: scores[0], # 業務量
      q2: scores[1], # 納期
      q3: scores[2], # 上司
      q4: scores[3], # 同僚
      q5: scores[4], # 環境
      total_score: total,
      comment: comments.sample,
      created_at: posted_at,
      updated_at: posted_at
    )
  end
end

puts "===================================="
puts "  初期データの投入が完了しました！"
puts "  --------------------------------"
puts "  Headquarters : #{Headquarter.count}"
puts "  Departments  : #{Department.count}"
puts "  Users        : #{User.count}"
puts "  Surveys      : #{Survey.count}"
puts "===================================="