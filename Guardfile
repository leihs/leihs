# A sample Guardfile
# More info at https://github.com/guard/guard#readme

## JASMINE
spec_location = "spec/javascripts/%s_spec"
guard 'jasmine-headless-webkit' do
  watch(%r{^app/views/.*\.jst$})
  watch(%r{^public/javascripts/(.*)\.js$}) { |m| newest_js_file(spec_location % m[1]) }
  watch(%r{^.*/assets/javascripts/(.*)\.(js|coffee)$}) { |m| newest_js_file(spec_location % m[1]) }
  watch(%r{^.*/assets/javascripts/(.*)\.(js.coffee)$}) { |m| "spec/javascripts/%s.js.coffee" % m[1] }
  watch(%r{^spec/javascripts/(.*)_spec\..*}) { |m| newest_js_file(spec_location % m[1]) }
end