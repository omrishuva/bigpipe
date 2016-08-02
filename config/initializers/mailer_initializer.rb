ActionMailer::Base.smtp_settings = {
  :user_name => 'omrishuva',
  :password => 'play123abc',
  :domain => 'http://www.activity.market',
  :address => 'smtp.sendgrid.net',
  :port => 2525,
  :authentication => :plain,
  :enable_starttls_auto => true
}
