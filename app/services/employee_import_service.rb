require 'csv'

class EmployeeImportService
  EXPECTED_HEADERS = ["社員番号", "氏名", "メールアドレス", "所属部署名"].freeze
  MAX_RECORDS = 50_000
  ERROR_LIMIT = 100

  attr_reader :errors, :valid_attributes

  def initialize(file)
    @file = file
    @errors = []
    @valid_attributes = []
    @employee_numbers_in_csv = Set.new
  end

  def execute
    return false unless valid_file?
    return false unless valid_headers?

    process_rows
    errors.empty?
  end

  private

  def valid_file?
    if @file.nil? || File.extname(@file.original_filename) != ".csv"
      @errors << "Please select a CSV file."
      return false
    end

    line_count = File.foreach(@file.path).count
    if line_count > MAX_RECORDS + 1
      @errors << "CSV contains too many records. (Max: #{MAX_RECORDS})"
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

  def process_rows
    CSV.foreach(@file.path, headers: true, encoding: 'BOM|UTF-8:UTF-8').with_index(2) do |row, i|
      break if @errors.size >= ERROR_LIMIT
      next if row.to_h.values.all?(&:blank?)

      validate_row(row, i)
    end
  end

  def validate_row(row, i)
    employee = Employee.new(
      employee_number: row["社員番号"],
      name:            row["氏名"],
      email:           row["メールアドレス"],
      department_name: row["所属部署名"]
    )

    # 重複チェック
    emp_num = row["社員番号"]
    if @employee_numbers_in_csv.include?(emp_num)
      @errors << "Row #{i}: Duplicate number in CSV."
    end
    @employee_numbers_in_csv.add(emp_num)

    unless employee.valid?
      employee.errors.full_messages.each { |msg| @errors << "Row #{i}: #{msg}" }
    end

    @valid_attributes << employee_attributes(row) if @errors.empty?
  end

  def employee_attributes(row)
    {
      employee_number: row["社員番号"],
      name:            row["氏名"],
      email:           row["メールアドレス"],
      department_name: row["所属部署名"],
      created_at:      Time.current,
      updated_at:      Time.current
    }
  end
end