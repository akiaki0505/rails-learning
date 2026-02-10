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
      unique_depts = service.prepare

      if unique_depts
        # ファイルを一時保存
        file_id = SecureRandom.uuid
        temp_path = Rails.root.join('tmp', "import_#{file_id}.csv")
        FileUtils.cp(params[:file].path, temp_path)

        # 成功: マッピング画面へ遷移 (同期的な動き)
        redirect_to mapping_stress_navi_employees_path(file_id: file_id)
      else
        # 失敗: 同じ画面を再表示し、エラーを渡す (同期的な動き)
        @csv_errors = service.errors
        # flash.now[:alert] = "Invalid CSV data found:" # 必要なら追加
        render :csv_upload, status: :unprocessable_entity
      end
    end

    def mapping
      @file_id = params[:file_id]
      file_path = Rails.root.join('tmp', "import_#{@file_id}.csv")

      # 安全のためファイル存在確認
      redirect_to employees_path, alert: "Session expired." unless File.exist?(file_path)

      # CSVから部署名を再抽出（サービスを使ってもOK）
      @unique_depts = []
      CSV.foreach(file_path, headers: true, encoding: 'BOM|UTF-8:UTF-8') do |row|
        @unique_depts << row["所属部署名"] unless row["所属部署名"].blank?
      end
      @unique_depts = @unique_depts.uniq

      # システム側の部署一覧
      @system_depts = Department.order(:name)
    end

    def finalize_import
      file_id = params[:file_id]
      mapping = params[:mapping]
      file_path = Rails.root.join('tmp', "import_#{file_id}.csv")

      # 安全のためファイル存在確認
      return render json: { alert: "Session expired. Please upload again." }, status: :unprocessable_entity unless File.exist?(file_path)

      service = EmployeeImportService.new(File.open(file_path))
      
      if service.import_with_mapping(mapping)
        # 成功したら一時ファイルを削除
        FileUtils.rm(file_path) if File.exist?(file_path)
        
        # JavaScript側にリダイレクト先を教える
        render json: { location: stress_navi_employees_path, notice: "Successfully imported employees!" }
      else
        render json: { alert: "Import failed: #{service.errors.join(', ')}" }, status: :unprocessable_entity
      end
    end

    private

    def csv_upload
      
    end

  end
end
