class GeminiService
  require 'faraday'
  require 'json'

  # URLは先ほど確認した "gemini-flash-latest" のままにしています
  API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent"

  def self.call(prompt)
    new.call(prompt)
  end

  def call(prompt)
    api_key = ENV['GEMINI_API_KEY']
    
    if api_key.blank?
      return "[Error] API key is missing. Please check your .env file."
    end

    conn = Faraday.new(url: API_URL) do |f|
      f.request :json
      f.response :json
      f.adapter Faraday.default_adapter
    end

    response = conn.post do |req|
      req.params['key'] = api_key
      req.headers['Content-Type'] = 'application/json'
      
      # Gemini API Structure
      req.body = {
        contents: [
          {
            parts: [
              { text: prompt }
            ]
          }
        ]
      }
    end

    if response.status == 200
      response.body.dig('candidates', 0, 'content', 'parts', 0, 'text') || "The response was empty."
    else
      Rails.logger.error("Gemini API Error: #{response.body}")
      "An error occurred during AI analysis. (Status: #{response.status})"
    end
    
  rescue => e
    Rails.logger.error("Gemini Connection Error: #{e.message}")
    "A connection error occurred: #{e.message}"
  end
end