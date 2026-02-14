require 'csv'

module StressNavi
  class EmployeesController < ApplicationController
    layout 'stressNavi/admin/application'
    def index
      @employees = Employee.order(id: :desc).limit(50)
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
      unique_depts = service.prepare

      if unique_depts
        file_id = SecureRandom.uuid
        temp_path = Rails.root.join('tmp', "import_#{file_id}.csv")
        FileUtils.cp(params[:file].path, temp_path)

        redirect_to mapping_stress_navi_employees_path(file_id: file_id)
      else
        @csv_errors = service.errors
        render :csv_upload, status: :unprocessable_entity
      end
    end

    def mapping
      @file_id = params[:file_id]
      file_path = Rails.root.join('tmp', "import_#{@file_id}.csv")

      redirect_to employees_path, alert: "Session expired." unless File.exist?(file_path)

      service = EmployeeImportService.new(File.open(file_path))
      @unique_depts = service.prepare 
      
      redirect_to employees_path, alert: "Invalid file content." unless @unique_depts

      @system_depts = Department.order(:name)
    end

    def finalize_import
      file_id = params[:file_id]
      mapping = params[:mapping]
      file_path = Rails.root.join('tmp', "import_#{file_id}.csv")

      return render json: { alert: "Session expired." }, status: :unprocessable_entity unless File.exist?(file_path)

      service = EmployeeImportService.new(File.open(file_path))
      
      if service.import_with_mapping(mapping)
        FileUtils.rm(file_path) if File.exist?(file_path)
        
        render json: { 
          location: stress_navi_employees_path, 
          notice: "Successfully imported employees!" 
        }
      else
        render json: { 
          alert: "Import failed:", 
          errors: service.errors 
        }, status: :unprocessable_entity
      end
    end

    def destroy_all
      Employee.delete_all 
      
      redirect_to stress_navi_employees_path, notice: "All employee records have been successfully deleted."
    end

    private

    def csv_upload
      
    end

  end
end
