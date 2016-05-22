OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '884004068377198', '47e2d8ca23dbafb448ec0433946a43c0'
end