# require './current_env'
require 'gcloud'
$gcloud = Gcloud.new "play-prod", "config/initializers/play-prod.json"
$datastore = $gcloud.datastore
$bigquery = $gcloud.bigquery
$storage = $gcloud.storage
$pubsub = $gcloud.pubsub