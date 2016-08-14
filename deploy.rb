require 'pry'
require "readline"
require './config/application'
require './config/initializers/gcloud'
require './app/models/entity'

class AppVersion < Entity
	
	attr_accessor :id, :app, :version_number, :branch, :developer, :created_at, :updated_at

	class << self
		
		def namespace
			"deployment"
		end

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
			app_version = (AppVersion.last.version_number.to_i + 1)
			AppVersion.create( created_at: Time.now.utc, app: app_name, version_number: app_version, branch: branch, developer: `whoami`  )
			app_version
		end

		def run_gcloud_sdk_deploy_commands
			version_number = create_new_version_number
			p "Deploying branch #{branch}"
			`gcloud preview datastore create-indexes config/db/index.yaml`
			`gcloud config set app/promote_by_default false`
			`gcloud config set app/stop_previous_version false`
			`gcloud preview app deploy --no-promote --version #{branch}-#{version_number}`
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
		
		def app_name
			"kommunal"
		end

	end
end

start_time = Time.now
AppVersion.deploy!
took = ((Time.now  - start_time)/60).round(2)
p "took #{took}" 
