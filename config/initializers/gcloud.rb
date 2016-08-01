# require './current_env'
require 'gcloud'
$gcloud = Gcloud.new "kommunal-1470050255366", "config/initializers/kommunal.json"
$datastore = $gcloud.datastore
$bigquery = $gcloud.bigquery
$storage = $gcloud.storage
$pubsub = $gcloud.pubsub