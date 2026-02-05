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
      
      if file.nil? || File.extname(file.original_filename) != ".csv"
        return redirect_to csv_upload_stress_navi_employees_path, alert: "Please select a CSV file."
      end

      line_count = File.foreach(file.path).count
      if line_count > 50001
        return redirect_to csv_upload_stress_navi_employees_path, alert: "CSV must contain 50,000 records or fewer (Current: #{line_count - 1} records)."
      end
      
      begin
        expected_headers = ["社員番号", "氏名", "メールアドレス", "所属部署名"]
        actual_headers = CSV.open(file.path, encoding: 'BOM|UTF-8:UTF-8', &:readline)&.map(&:strip)

        if actual_headers.nil?
          return redirect_to csv_upload_stress_navi_employees_path, alert: "CSV file is empty."
        end

        missing = expected_headers - actual_headers
        extra = actual_headers - expected_headers

        if missing.any? || extra.any?
          msg = []
          msg << "Missing: #{missing.join(', ')}" if missing.any?
          msg << "Unexpected: #{extra.join(', ')}" if extra.any?
          return redirect_to csv_upload_stress_navi_employees_path, alert: "Invalid Header - #{msg.join(' / ')}"
        end

        errors = []
        employee_numbers_in_csv = Set.new
        employees_to_save = []

        CSV.foreach(file.path, headers: true, encoding: 'BOM|UTF-8:UTF-8') do |row|
          employee = Employee.new(
            employee_number: row["社員番号"],
            name:            row["氏名"],
            email:           row["メールアドレス"],
            department_name: row["所属部署名"]
          )

          # CSV内の重複チェック
          emp_num = row["社員番号"]
          if employee_numbers_in_csv.include?(emp_num)
            errors << "Row #{$.}: Duplicate employee number (#{emp_num}) in CSV."
          end
          employee_numbers_in_csv.add(emp_num)

          unless employee.valid?
            employee.errors.full_messages.each do |message|
              errors << "Row #{$.}: #{message}"
            end
          end

          # エラーがなければ、保存リストに追加
          employees_to_save << employee if errors.empty?
        end

        if errors.any?
          @csv_errors = errors
          flash.now[:alert] = "Please fix the errors below and try again."
          render :csv_upload, status: :unprocessable_entity
        else
          if employees_to_save.any?
            attributes_list = employees_to_save.map do |e|
              e.attributes.except("id", "created_at", "updated_at").merge(
                "created_at" => Time.current,
                "updated_at" => Time.current
              )
            end
            Employee.insert_all(attributes_list)
          end

          redirect_to stress_navi_employees_path, notice: "Successfully imported #{employees_to_save.size} employees."
        end

        rescue => e
          redirect_to csv_upload_stress_navi_employees_path, alert: "An unexpected error occurred: #{e.message}"
      end
    end

    private

    def csv_upload
      
    end

  end
end
