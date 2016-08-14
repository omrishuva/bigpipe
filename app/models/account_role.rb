class AccountRole < Entity
	attr_accessor :id, :account_id, :user_id, :status, :role_id, :status, :created_at, :updated_at
	before_save :set_pending_status, unless:  :has_status?

	def set_pending_status
		self.status = "pending"
	end

	def has_status?
		self.status.present?
	end

end