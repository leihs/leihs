begin
  p "Deploying tag: #{tag}"
  set :branch, tag
rescue
  raise "You have to specify a tag to deploy, for example: cap stagename deploy -s tag=3.2.0"
end
