ActionMailer::Base.smtp_settings = {
  :user_name => 'omrishuva',
  :password => 'play123abc',
  :domain => 'play.org.il',
  :address => 'smtp.sendgrid.net',
  :port => 2525,
  :authentication => :plain,
  :enable_starttls_auto => true
}