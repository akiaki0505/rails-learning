module ApplicationHelper
    def full_title(page_title = "")
        base_title = "MyRailsApp"
        page_title.present? ? "#{page_title} | #{base_title}" : base_title
    end

    def markdown(text)
    return "" if text.blank?

    # Markdownのオプション設定
    options = {
      filter_html:     false, # Geminiからの出力を信じるならfalse、より安全にするならtrue
      hard_wrap:       true,  # 改行を<br>に変換
      link_attributes: { rel: 'nofollow', target: "_blank" },
      space_after_headers: true,
      fenced_code_blocks: true
    }

    # 解析の拡張設定（テーブルなどを有効化）
    extensions = {
      autolink:           true,
      superscript:        true,
      tables:             true, # ★これが重要！表を表示できるようにします
      strikethrough:      true,
      no_intra_emphasis:  true,
      fenced_code_blocks: true
    }

    renderer = Redcarpet::Render::HTML.new(options)
    markdown = Redcarpet::Markdown.new(renderer, extensions)

    # HTMLとして安全な文字列として返す
    # 外部からの入力なので念のため sanitize を通すのがベスト
    sanitize(markdown.render(text)).html_safe
  end
end
