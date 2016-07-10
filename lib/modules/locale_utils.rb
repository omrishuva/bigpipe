module LocaleUtils
	def set_locale
    self.locale = I18n.locale.to_s
  end
  
  def has_locale?
    self.locale.present?
  end
end