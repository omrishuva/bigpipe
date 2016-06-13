desc "Run task queue worker"
task run_worker: :environment do
  x = true
  while x == true do
  	p "x"
  end

end