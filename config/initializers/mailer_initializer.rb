ActionMailer::Base.smtp_settings = {
  :user_name => 'omrishuva',
  :password => 'play123abc',
  :domain => 'play.org.il',
  :address => 'smtp.sendgrid.net',
  :port => 587,
  :authentication => :plain,
  :enable_starttls_auto => true
}