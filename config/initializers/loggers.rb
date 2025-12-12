#ログファイルの保存場所を定義
login_log_path = Rails.root.join('log', 'login.log')
user_log_path  = Rails.root.join('log', 'user.log')

LOGIN_LOGGER = Logger.new(login_log_path)
USER_LOGGER  = Logger.new(user_log_path)

formatter = proc do |severity, datetime, progname, msg|
  "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{severity} -- : #{msg}\n"
end

LOGIN_LOGGER.formatter = formatter
USER_LOGGER.formatter  = formatter