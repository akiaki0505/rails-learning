module Admin::DashboardsHelper
  def weather_icon_svg(type)
    case type
    when :mist
      # 🌫️ 霧（データなし）
      <<-SVG.html_safe
        <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M3 7h12" />
          <path d="M9 12h12" />
          <path d="M5 17h10" />
        </svg>
      SVG
    when :partly_cloudy
      # 🌤️ 晴れ時々曇り
      <<-SVG.html_safe
        <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
           <g class="text-orange-500" stroke="currentColor">
             <path d="M12 2v2" />
             <path d="m4.93 4.93 1.41 1.41" />
             <path d="M20 12h2" />
             <path d="m19.07 4.93-1.41 1.41" />
             <path d="M15.947 12.65a4 4 0 0 0-5.925-4.128" />
           </g>
           
           <path d="M13 22H7a5 5 0 1 1 4.9-6H13a3 3 0 0 1 0 6Z" class="text-gray-400" stroke="currentColor" />
        </svg>
      SVG
    when :sunny
      # ☀️ 太陽
      <<-SVG.html_safe
        <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="12" cy="12" r="4"></circle>
          <path d="M12 2v2"></path>
          <path d="M12 20v2"></path>
          <path d="M4.93 4.93l1.41 1.41"></path>
          <path d="M17.66 17.66l1.41 1.41"></path>
          <path d="M2 12h2"></path>
          <path d="M20 12h2"></path>
          <path d="M6.34 17.66l-1.41 1.41"></path>
          <path d="M19.07 4.93l-1.41 1.41"></path>
        </svg>
      SVG

    when :cloudy
      # ☁️ 雲（スタンダードなふわふわ型）
      <<-SVG.html_safe
        <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M17.5 19C19.985 19 22 16.985 22 14.5C22 12.132 20.177 10.244 17.819 10.035C17.344 6.658 14.427 4 11 4C7.573 4 4.656 6.658 4.181 10.035C1.823 10.244 0 12.132 0 14.5C0 16.985 2.015 19 4.5 19L17.5 19Z"></path>
        </svg>
      SVG

    when :rainy
      # ☔️ 雨（雲の下に雫）
      <<-SVG.html_safe
        <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M4 14.899A7 7 0 1 1 15.71 8h1.79a4.5 4.5 0 0 1 2.5 8.242"></path>
          <path d="M16 14v6"></path>
          <path d="M8 14v6"></path>
          <path d="M12 16v6"></path>
        </svg>
      SVG

    else # :stormy
      # ⛈️ 雷（雲とイナズマ）
      <<-SVG.html_safe
        <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M19 16.9A5 5 0 0 0 18 7h-1.26a8 8 0 1 0-11.62 9"></path>
          <polyline points="13 11 9 17 15 17 11 23"></polyline>
        </svg>
      SVG
    end
  end

  def weather_styles(type)
    case type
    when :mist
      { bg: "bg-gray-50 border-gray-100", text: "text-gray-300", label: "No Data" }
    when :sunny
      { bg: "bg-orange-50 border-orange-100", text: "text-orange-500", label: "Sunny" }
    when :cloudy
      { bg: "bg-gray-50 border-gray-200", text: "text-gray-500", label: "Cloudy" }
    when :rainy
      { bg: "bg-blue-50 border-blue-100", text: "text-blue-500", label: "Rainy" }
    else # stormy
      { bg: "bg-purple-50 border-purple-100", text: "text-purple-600", label: "Stormy" }
    end
  end

  def score_to_weather_type(score)
    return :mist if score.nil?

    if score < 11.0
      :sunny      # 5 ~ 10.9点
    elsif score < 16.0
      :cloudy     # 11 ~ 15.9点
    elsif score < 20.0
      :rainy      # 16 ~ 19.9点
    else
      :stormy     # 20点以上
    end
  end

end