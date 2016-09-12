class AccountsController < ApplicationController

	skip_before_action :verify_authenticity_token, only: [:upgrade_to_business_account]

	def upgrade_to_business_account
		current_user.current_account.upgrade_to_bussiness_account
		respond_to do |format|
      format.js { }
    end
	end

	def account_setup
		if current_user.current_account
			@account = current_user.current_account
		else
			@account = Account.create_freelancer_account( current_user )
		end
	end

end