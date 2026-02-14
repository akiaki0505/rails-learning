# app/services/employee_import_service.rb
require 'csv'

class EmployeeImportService
  EXPECTED_HEADERS = ["社員番号", "氏名", "メールアドレス", "所属部署名"].freeze
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  MAX_RECORDS = 50_000
  ERROR_LIMIT = 100

  attr_reader :errors

  def initialize(file)
    @file = file
    @errors = []
  end

  # --- ステップ1: ファイル検証 ＋ データバリデーション ＋ 部署抽出 ---
  def prepare
    return false unless valid_file?
    return false unless valid_headers?

    unique_depts = Set.new
    csv_employee_numbers = Set.new
    existing_numbers = Employee.pluck(:employee_number).to_set

    begin
      CSV.foreach(@file.path, headers: true, encoding: 'BOM|UTF-8:UTF-8').with_index(2) do |row, i|
        next if row.to_h.values.all?(&:blank?)

        emp_num = row["社員番号"]
        email = row["メールアドレス"]
        dept_name = row["所属部署名"]

        # 1. 社員番号チェック
        if emp_num.blank?
          @errors << "Row #{i}: Employee number is required."
        elsif csv_employee_numbers.include?(emp_num)
          @errors << "Row #{i}: Duplicate employee number in CSV (#{emp_num})."
        elsif existing_numbers.include?(emp_num)
          @errors << "Row #{i}: Employee number #{emp_num} already exists in database."
        end
        csv_employee_numbers.add(emp_num)

        # 2. メールアドレス形式チェック
        if email.blank?
          @errors << "Row #{i}: Email is required."
        elsif !email.match?(EMAIL_REGEX)
          @errors << "Row #{i}: Email format is invalid (#{email})."
        end

        # 3. 部署名の存在確認（CSV内）
        if dept_name.blank?
          @errors << "Row #{i}: Department name is required."
        else
          unique_depts << dept_name
        end

        break if @errors.size >= ERROR_LIMIT
      end
    rescue => e
      @errors << "CSV processing error: #{e.message}"
      return false
    end

    return false if @errors.any?
    unique_depts.to_a.sort
  end

  # --- ステップ2: 最終インポート（ここではマッピングの適用のみ） ---
  def import_with_mapping(mapping_hash)
    valid_attributes = []

    CSV.foreach(@file.path, headers: true, encoding: 'BOM|UTF-8:UTF-8') do |row|
      next if row.to_h.values.all?(&:blank?)

      csv_dept_name = row["所属部署名"]
      dept_id = mapping_hash[csv_dept_name]

      mapping_hash.each do |csv_dept_name, dept_id|
        if dept_id.blank?
          @errors << "Please select a system department for '#{csv_dept_name}'."
        end
      end

      return false if @errors.any?

      valid_attributes << {
        department_id:   dept_id,
        employee_number: row["社員番号"],
        name:            row["氏名"],
        email:           row["メールアドレス"],
        department_name: csv_dept_name,
        created_at:      Time.current,
        updated_at:      Time.current
      }
    end

    Employee.insert_all(valid_attributes) if valid_attributes.any?
    true
  rescue => e
    @errors << "Database error: #{e.message}"
    false
  end

  private

  def valid_file?
    filename = @file.try(:original_filename) || File.basename(@file.path)

    if @file.nil? || File.extname(filename).downcase != ".csv"
      @errors << "Please select a valid CSV file."
      return false
    end

    if File.foreach(@file.path).count > MAX_RECORDS + 1
      @errors << "CSV contains too many records (Max: #{MAX_RECORDS})."
      return false
    end
    true
  end

  def valid_headers?
    actual = CSV.open(@file.path, encoding: 'BOM|UTF-8:UTF-8', &:readline)&.map(&:strip)
    missing = EXPECTED_HEADERS - (actual || [])
    return true if missing.empty?
    @errors << "Missing columns: #{missing.join(', ')}"
    false
  end
end