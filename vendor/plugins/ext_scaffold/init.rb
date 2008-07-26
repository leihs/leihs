# Load CoreExtensions
Dir[File.join("#{File.dirname(__FILE__)}", 'lib', 'ext_scaffold_core_extensions', '**', '*.rb')].each do |f|
  extension_module = f.sub(/(.*)(ext_scaffold_core_extensions.*)\.rb/,'\2').classify.constantize
  base_module = f.sub(/(.*ext_scaffold_core_extensions.)(.*)\.rb/,'\2').classify.constantize
  base_module.class_eval { include extension_module }
end

# Register MIME type
Mime::Type.register_alias "text/javascript", :ext_json
