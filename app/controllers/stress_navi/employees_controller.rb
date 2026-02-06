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
      service = EmployeeImportService.new(params[:file])

      if service.execute
        Employee.insert_all(service.valid_attributes) if service.valid_attributes.any?
        render json: { notice: "Successfully imported #{service.valid_attributes.size} employees!" }
      else
        render json: { 
          alert: "CSV import failed.", 
          errors: service.errors 
        }, status: :unprocessable_entity
      end
    rescue => e
      render json: { alert: "Unexpected error: #{e.message}" }, status: :internal_server_error
    end

    private

    def csv_upload
      
    end

  end
end
