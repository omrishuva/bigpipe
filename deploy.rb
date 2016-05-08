require "readline"
require './initializers/gcloud'
require './entities/abstract_entity'

class AppVersion < Entity
	
	class << self

		def deploy!
			answer = user_deployment_approval
			if answer == "y" || answer == ""
				if working_directory_is_clean?
					run_gcloud_sdk_deploy_commands
				else
					show_git_issues_message
				end
			elsif answer == "n"
				p "Stopped deployment"
			end
		end

		def working_directory_is_clean?
			`git status`.include?( "nothing to commit, working directory clean") && !`git status`.include?( 'use "git push" to publish your local commits')
		end

		def create_new_version_number
			app_version =  self.last[0]["version_number"] rescue 0
			new_version_number = app_version + 1
			self.create( version_number: new_version_number )[0]["version_number"]
		end

		def run_gcloud_sdk_deploy_commands
			p "Deploying branch #{branch}"
			`gcloud config set app/promote_by_default false`
			`gcloud config set app/stop_previous_version false`
			`gcloud preview app deploy --no-promote --version #{branch}-#{create_new_version_number}`
		end

		def show_git_issues_message
			p "There are unstaged changes on branch #{branch} or either local branch is ahead/behind remote #{branch}"
			p "Please fix this issue before deploying"
		end
		
		def user_deployment_approval
			p "Deploy branch #{branch} ? (y/n)"
			Readline.readline
		end
		
		def branch
			@current_branch ||= `git rev-parse --abbrev-ref HEAD`.split("\n")[0]
		end
		
	end
end

AppVersion.deploy!
