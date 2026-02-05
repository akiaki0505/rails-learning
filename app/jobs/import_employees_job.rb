require 'csv'

class ImportEmployeesJob < ApplicationJob
  queue_as :default

  def perform(file_path)
    errors = []
    employee_numbers_in_csv = Set.new
    valid_attributes = [] # 保存用のデータを貯める配列

    begin
      # 1行ずつバリデーションを行う
      CSV.foreach(file_path, headers: true, encoding: 'BOM|UTF-8:UTF-8') do |row|
        # チェック用に一時オブジェクトを作成
        employee = Employee.new(
          employee_number: row["社員番号"],
          name:            row["氏名"],
          email:           row["メールアドレス"],
          department_name: row["所属部署名"]
        )

        # ① CSV内での重複チェック
        emp_num = row["社員番号"]
        if employee_numbers_in_csv.include?(emp_num)
          errors << "Row #{$.}: Duplicate employee number (#{emp_num}) in CSV."
        end
        employee_numbers_in_csv.add(emp_num)

        # ② モデルのバリデーション (空チェック・形式など)
        unless employee.valid?
          employee.errors.full_messages.each { |msg| errors << "Row #{$.}: #{msg}" }
        end

        # エラーがなければ、一括保存用のハッシュを作成
        if errors.empty?
          valid_attributes << {
            employee_number: row["社員番号"],
            name:            row["氏名"],
            email:           row["メールアドレス"],
            department_name: row["所属部署名"],
            created_at:      Time.current,
            updated_at:      Time.current
          }
        end

        # エラーが100件を超えたら中断
        if errors.size >= 100
          errors << "Too many errors. Stopping validation."
          break
        end
      end

      # --- 保存処理 ---
      if errors.any?
        # 本来はここでエラーをユーザーに通知する仕組み（メール等）が必要ですが、
        # まずはログに出力します
        Rails.logger.error "Import Failed. Errors: #{errors.join(', ')}"
      else
        # 1000件ずつ一括保存（バルクインサート）
        valid_attributes.each_slice(1000) do |batch|
          Employee.insert_all(batch)
        end
        Rails.logger.info "Successfully imported #{valid_attributes.size} employees."
      end

    rescue => e
      Rails.logger.error "Unexpected Error: #{e.message}"
    ensure
      # 成功・失敗に関わらず一時ファイルを削除
      File.delete(file_path) if File.exist?(file_path)
    end
  end
end