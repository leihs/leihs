# create benchmarker instance
RAILS_BENCHMARKER = RailsBenchmark.new

# If your session storage is ActiveRecordStore, and if you want
# sessions to be automatically deleted after benchmarking, use
# RAILS_BENCHMARKER = RailsBenchmarkWithActiveRecordStore.new

# WARNING: don't use RailsBenchmarkWithActiveRecordStore running on
# your production database!

# If your application runs from a url which is not your servers root,
# you should set relative_url_root on the benchmarker instance,
# especially if you use page caching.
# RAILS_BENCHMARKER.relative_url_root = '/blog'

# Create session data required to run the benchmark.
# Customize the code below if your benchmark needs session data.

require 'user'
RAILS_BENCHMARKER.session_data = {
  :user => User.find_by_id(53), 
  :aktiver_geraetepark => 1
}
