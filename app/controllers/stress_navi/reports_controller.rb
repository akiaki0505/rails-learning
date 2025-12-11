module StressNavi
  class ReportsController < ApplicationController
    layout 'stressNavi/admin/application'
    def index
      @headquarters = Headquarter.includes(:departments).order(:id)
    end

    def analyze
      target_name = params[:name]
      
      organization = Headquarter.find_by(name: target_name) || Department.find_by(name: target_name)

      unless organization
        render json: { error: "Organization not found" }, status: 404
        return
      end

      # 紐づくSurveyデータを取得
      surveys = organization.surveys

      if surveys.empty?
        render json: { 
          name: target_name,
          score: 0,
          analysis: "No data available yet. Please ask employees to complete the stress check."
        }
        return
      end

      avg_total = surveys.average(:total_score).to_f.round(1)
      avg_q1    = surveys.average(:q1).to_f.round(1)          # 業務量
      avg_q4    = surveys.average(:q4).to_f.round(1)          # 人間関係

      prompt = <<~TEXT
        あなたはプロの組織コンサルタントです。
        クライアント組織「#{target_name}」のストレスチェック集計結果を分析してください。

        【集計データ (N=#{surveys.count}名)】
        - 総合ストレススコア: #{avg_total} / 25点満点 (点数が高いほどストレスが高く危険)
        - 業務量の負担(Q1): #{avg_q1} / 5.0 (高いほど負担大)
        - 職場の人間関係(Q4): #{avg_q4} / 5.0 (高いほど関係悪化)

        【依頼】
        この数値を元に、現在の組織コンディションを診断し、管理職が優先して取り組むべき改善アクションを3つ提案してください。
        語り口は「産業医のように冷静かつ、従業員に寄り添う姿勢」でお願いします。
      TEXT

      #Gemini API を呼び出す
      result_text = GeminiService.call(prompt)

      render json: { 
        name: target_name,
        score: avg_total,
        analysis: result_text 
      }
    end
  end
end