# require './current_env'
require 'gcloud'
$gcloud = Gcloud.new "kommunal-1383", "config/initializers/kommunal.json"
$datastore = $gcloud.datastore
$bigquery = $gcloud.bigquery
$storage = $gcloud.storage
$pubsub = $gcloud.pubsub