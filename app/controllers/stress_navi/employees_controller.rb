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
          # ここで return されるので、ジョブは実行されません
          return redirect_to csv_upload_stress_navi_employees_path, alert: "Invalid Header. #{msg.join(' / ')}"
        end
        
        # 3. 非同期処理への準備
        temp_path = Rails.root.join('tmp', "import_#{Time.current.to_i}.csv")
        FileUtils.cp(file.path, temp_path)
        
        ImportEmployeesJob.perform_later(temp_path.to_s)
        
        redirect_to stress_navi_employees_path, notice: "Import started! It will be processed in the background."
      
      rescue => e
        redirect_to csv_upload_stress_navi_employees_path, alert: "Error: #{e.message}"
      end
    end

    private

    def csv_upload
      
    end

  end
end
