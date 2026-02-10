require 'csv'

class EmployeeImportService
  EXPECTED_HEADERS = ["社員番号", "氏名", "メールアドレス", "所属部署名"].freeze
  MAX_RECORDS = 50_000
  ERROR_LIMIT = 100

  attr_reader :errors

  def initialize(file)
    @file = file
    @errors = []
  end

  # --- ステップ1: ファイルの検証とユニークな部署名の抽出 ---
  def prepare
    return false unless valid_file?
    return false unless valid_headers?

    unique_depts = Set.new
    begin
      CSV.foreach(@file.path, headers: true, encoding: 'BOM|UTF-8:UTF-8') do |row|
        next if row.to_h.values.all?(&:blank?)
        unique_depts << row["所属部署名"] if row["所属部署名"].present?
      end
    rescue => e
      @errors << "CSV processing error: #{e.message}"
      return false
    end

    unique_depts.to_a.sort
  end

  # --- ステップ2: 最終的なインポート処理 ---
  def import_with_mapping(mapping_hash)
    valid_attributes = []
    # 重複チェック用
    employee_numbers_in_csv = Set.new

    CSV.foreach(@file.path, headers: true, encoding: 'BOM|UTF-8:UTF-8').with_index(2) do |row, i|
      next if row.to_h.values.all?(&:blank?)

      # 画面から渡されたマッピング情報に基づいて department_id を決定
      dept_id = mapping_hash[row["所属部署名"]]

      valid_attributes << {
        department_id:   dept_id,
        employee_number: row["社員番号"],
        name:            row["氏名"],
        email:           row["メールアドレス"],
        department_name: row["所属部署名"],
        created_at:      Time.current,
        updated_at:      Time.current
      }
    end

    # ここでバルクインサート
    Employee.insert_all(valid_attributes) if valid_attributes.any?
    true
  rescue => e
    @errors << "Database error: #{e.message}"
    false
  end

  private

  def valid_file?
    if @file.nil? || File.extname(@file.original_filename) != ".csv"
      @errors << "Please select a CSV file."
      return false
    end

    # 行数チェック
    line_count = File.foreach(@file.path).count
    if line_count > MAX_RECORDS + 1
      @errors << "CSV contains too many records (Max: #{MAX_RECORDS})."
      return false
    end
    true
  end

  def valid_headers?
    actual_headers = CSV.open(@file.path, encoding: 'BOM|UTF-8:UTF-8', &:readline)&.map(&:strip)
    if actual_headers.nil?
      @errors << "The CSV file is empty."
      return false
    end

    missing = EXPECTED_HEADERS - actual_headers
    extra = actual_headers - EXPECTED_HEADERS

    if missing.any? || extra.any?
      @errors << "Missing columns: #{missing.join(', ')}" if missing.any?
      @errors << "Unexpected columns: #{extra.join(', ')}" if extra.any?
      return false
    end
    true
  end
end