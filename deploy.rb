require 'pry'
require "readline"
require './config/initializers/gcloud'
require './app/models/entity'

class AppVersion < entity
	
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
			binding.pry
			last_version_query = $datastore.query.kind(app_name).where( "branch", "=", branch ).order("created_at", :desc).limit(1)
			app_version =  $datastore.run( last_version_query, namespace: "app_versions" )[0]["version_number"] rescue 0
			new_version_number = app_version + 1
			new_app_version_entity =  $datastore.entity app_name do |e|
																	e["created_at"] = Time.now.utc
																	e["version_number"] = new_version_number
																	e["branch"] = branch
																	e["developer"] = `whoami`
																	e.key.namespace = "app_versions"
																end
			$datastore.save(new_app_version_entity)[0]["version_number"]
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
