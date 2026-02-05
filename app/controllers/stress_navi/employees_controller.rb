require 'csv'

module StressNavi
  class EmployeesController < ApplicationController
    layout 'stressNavi/admin/application'
    def index
      @employees = Employee.order(id: :desc)
    end

    def download_format
      header = ["社員番号", "氏名", "メールアドレス", "所属部署名"]

      generated_csv = CSV.generate do |csv|
        csv << header
        csv << ["1", "山田 太郎", "test@example.com", "営業部"]
      end

      bom = "\uFEFF"
      send_data(bom + generated_csv, filename: "employees_import_format.csv", type: :csv)
    end

    def import_csv
      file = params[:file]
      errors = []

      # 1. 形式チェック
      if file.nil? || File.extname(file.original_filename) != ".csv"
        return render json: { alert: "Please select a CSV file." }, status: :unprocessable_entity
      end

      # 2. レコード数チェック (5万件以下)
      line_count = File.foreach(file.path).count
      if line_count > 50001
        return render json: { 
          alert: "CSV contains too many records. Please ensure it has 50,000 records or fewer (Current: #{line_count - 1} records)." 
          }, status: :unprocessable_entity
      end

      begin
        # 3. ヘッダーチェック
        expected_headers = ["社員番号", "氏名", "メールアドレス", "所属部署名"]
        actual_headers = CSV.open(file.path, encoding: 'BOM|UTF-8:UTF-8', &:readline)&.map(&:strip)
        
        if actual_headers.nil?
          return render json: { alert: "The CSV file is empty." }, status: :unprocessable_entity
        end

        missing = expected_headers - actual_headers
        extra = actual_headers - expected_headers

        if missing.any? || extra.any?
          header_errors = []
          header_errors << "Missing columns: #{missing.join(', ')}" if missing.any?
          header_errors << "Unexpected columns: #{extra.join(', ')}" if extra.any?
      
          return render json: { 
            alert: "Invalid CSV header.", 
            errors: header_errors 
          }, status: :unprocessable_entity
        end

        # 4. データバリデーション
        errors = []
        employee_numbers_in_csv = Set.new
        valid_attributes = []

        CSV.foreach(file.path, headers: true, encoding: 'BOM|UTF-8:UTF-8') do |row|
          employee = Employee.new(
            employee_number: row["社員番号"],
            name:            row["氏名"],
            email:           row["メールアドレス"],
            department_name: row["所属部署名"]
          )

          # 重複チェック等
          emp_num = row["社員番号"]
          errors << "Row #{$.}: Duplicate number in CSV." if employee_numbers_in_csv.include?(emp_num)
          employee_numbers_in_csv.add(emp_num)

          unless employee.valid?
            employee.errors.full_messages.each { |msg| errors << "Row #{$.}: #{msg}" }
          end

          valid_attributes << {
            employee_number: row["社員番号"], name: row["氏名"],
            email: row["メールアドレス"], department_name: row["所属部署名"],
            created_at: Time.current, updated_at: Time.current
          } if errors.empty?

          break if errors.size >= 100
        end

        # 5. レスポンスの返却
        if errors.any?
          render json: { errors: errors }, status: :unprocessable_entity
        else
          Employee.insert_all(valid_attributes) if valid_attributes.any?
          render json: { notice: "Successfully imported #{valid_attributes.size} employees!" }
        end

      rescue => e
        render json: { alert: "Unexpected error: #{e.message}" }, status: :internal_server_error
      end
    end

    private

    def csv_upload
      
    end

  end
end
